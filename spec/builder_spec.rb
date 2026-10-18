# frozen_string_literal: true

RSpec.describe Eldr::Builder do
  describe '#use' do
    it 'supports passing an array of middleware' do
      builder = described_class.new
      builder.use Class.new
      builder_2 = described_class.new
      builder_2.use builder.middleware
      expect(builder_2.middleware).to eq(builder.middleware)
    end

    it 'records middleware as builder procs that wrap the app' do
      builder = described_class.new
      middleware = Class.new do
        def initialize(app) = @app = app
        def call(env) = @app.call(env)
      end
      builder.use middleware
      expect(builder.middleware.length).to eq(1)
      app = proc { [200, {}, ['ok']] }
      wrapped = builder.middleware.first[app]
      expect(wrapped).to be_an_instance_of(middleware)
    end
  end

  describe '#use after #map' do
    subject(:app) { builder.to_app }

    let(:middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          [status, headers.merge('x-mw' => '1'), body]
        end
      end
    end
    let(:index) { proc { |_env| [200, { 'content-type' => 'text/plain' }, ['index']] } }
    let(:cats)  { proc { |_env| [200, { 'content-type' => 'text/plain' }, ['cats']] } }
    let(:builder) do
      # Mapped blocks are instance_eval'ed on a fresh Builder inside
      # generate_map, where let/subject helpers are not visible — capture
      # into a local first.
      cats_app = cats
      b = described_class.new
      b.map '/cats' do
        run cats_app
      end
      b.use middleware
      b.run index
      b
    end

    it 'wraps the default app in the middleware and mounts it at /' do
      expect(app).to be_an_instance_of(Rack::URLMap)
      resp = app.call(Rack::MockRequest.env_for('/', method: :get))
      expect(resp[2]).to eq(['index'])
      expect(resp[1]['x-mw']).to eq('1')
    end

    it 'routes mapped paths to their own apps, bypassing the middleware' do
      resp = app.call(Rack::MockRequest.env_for('/cats', method: :get))
      expect(resp[2]).to eq(['cats'])
      expect(resp[1]['x-mw']).to be_nil
    end

    it 'consumes the pending map' do
      app
      expect(builder.instance_variable_get(:@map)).to be_nil
    end
  end

  describe '#warmup' do
    let(:inner) { proc { |_env| [200, {}, ['ok']] } }

    it 'invokes the warmup block with the built app' do
      seen = nil
      builder = described_class.new
      builder.warmup { |app| seen = app }
      builder.run inner
      expect(builder.to_app).to eq(seen)
    end

    it 'accepts a proc argument' do
      seen = nil
      builder = described_class.new
      builder.warmup(proc { |app| seen = app })
      builder.run inner
      expect(builder.to_app).to eq(seen)
    end
  end

  describe '#map / #to_app / generate_map' do
    it 'builds a Rack::URLMap mounting multiple apps at different paths' do
      index = proc { |_env| [200, { 'content-type' => 'text/plain' }, ['index']] }
      cats  = proc { |_env| [200, { 'content-type' => 'text/plain' }, ['cats']] }
      builder = described_class.new
      builder.map '/' do
        run index
      end
      builder.map '/cats' do
        run cats
      end
      app = builder.to_app
      expect(app).to be_an_instance_of(Rack::URLMap)
      expect(app.call(Rack::MockRequest.env_for('/', { method: :get }))[2]).to eq(['index'])
      expect(app.call(Rack::MockRequest.env_for('/cats', { method: :get }))[2]).to eq(['cats'])
    end

    it 'raises when neither run nor map is provided' do
      expect { described_class.new.to_app }.to raise_error(/missing run or map statement/)
    end
  end

  describe '.app' do
    it 'returns a built app (the proc) when run is given' do
      app = described_class.app { run proc { |_env| [200, {}, ['hello']] } }
      expect(app.call('PATH_INFO' => '/', 'REQUEST_METHOD' => 'GET')[2]).to eq(['hello'])
    end
  end

  describe 'Rack::Builder parity' do
    let(:middleware) do
      Class.new do
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          [status, headers.merge('x-mw' => '1'), body]
        end
      end
    end
    let(:index) { proc { |_env| [200, { 'content-type' => 'text/plain' }, ['index']] } }
    let(:cats)  { proc { |_env| [200, { 'content-type' => 'text/plain' }, ['cats']] } }

    def snapshot(app)
      %w[/ /cats].map do |path|
        status, headers, body = app.call(Rack::MockRequest.env_for(path, method: :get))
        [status, headers['x-mw'], body]
      end
    end

    # Builds the same stack with Eldr::Builder and Rack::Builder. Mapped
    # blocks are instance_eval'ed on a fresh builder, so capture the apps
    # into locals first.
    def build_pair(&steps)
      cats_app = cats
      eldr = Eldr::Builder.new
      rack = Rack::Builder.new
      [eldr, rack].each { |builder| steps.call(builder, cats_app) }
      [eldr.to_app, rack.to_app]
    end

    it 'matches Rack::Builder when use precedes map (middleware wraps the URLMap)' do
      eldr, rack = build_pair do |builder, cats_app|
        builder.use middleware
        builder.map('/cats') { run cats_app }
        builder.run index
      end

      expect(snapshot(eldr)).to eq(snapshot(rack))
      expect(snapshot(eldr)).to eq([[200, '1', ['index']], [200, '1', ['cats']]])
    end

    it 'matches Rack::Builder when use follows map (mapped paths bypass it)' do
      eldr, rack = build_pair do |builder, cats_app|
        builder.map('/cats') { run cats_app }
        builder.use middleware
        builder.run index
      end

      expect(snapshot(eldr)).to eq(snapshot(rack))
      expect(snapshot(eldr)).to eq([[200, '1', ['index']], [200, nil, ['cats']]])
    end

    it 'matches Rack::Builder when use is inside a map block (scoped to that branch)' do
      mw = middleware
      eldr, rack = build_pair do |builder, cats_app|
        builder.map('/cats') do
          use mw
          run cats_app
        end
        builder.run index
      end

      expect(snapshot(eldr)).to eq(snapshot(rack))
      expect(snapshot(eldr)).to eq([[200, nil, ['index']], [200, '1', ['cats']]])
    end
  end
end
