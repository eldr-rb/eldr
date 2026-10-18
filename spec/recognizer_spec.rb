# frozen_string_literal: true

RSpec.describe Eldr::Recognizer do
  describe '#call' do
    subject(:app) do
      bob = Class.new(Eldr::App)
      bob.get '/cats', resp_proc
      bob
    end

    let(:resp_proc) { proc { [200, {}, ['Hello Bob!']] } }

    let(:recognizer) { described_class.new(app.routes) }

    context 'when there are matching routes' do
      let(:env) do
        Rack::MockRequest.env_for('/cats', { method: :get })
      end

      it 'returns matching routes' do
        expect(recognizer.call(env).length).to eq(1)
      end
    end

    context 'when there are no matching routes' do
      let(:env) do
        Rack::MockRequest.env_for('/no-route-for-me', { method: :get })
      end

      it 'raises a NotFound error' do
        expect { recognizer.call(env) }.to raise_error(Eldr::Recognizer::NotFound)
      end
    end

    context 'when PATH_INFO is blank' do
      let(:env) { { 'PATH_INFO' => '', 'REQUEST_METHOD' => 'GET' } }

      before { app.get '/', resp_proc }

      it 'normalizes it to / and returns the root route' do
        expect(recognizer.call(env).length).to eq(1)
      end
    end
  end

  describe '#verb' do
    let(:app) do
      bob = Class.new(Eldr::App)
      bob.post '/cats', proc { [201, {}, ['']] }
      bob
    end
    let(:recognizer) { described_class.new(app.routes) }

    it 'downcases the REQUEST_METHOD before looking up routes' do
      env = Rack::MockRequest.env_for('/cats', { method: :post })
      recognizer.call(env)
      expect(recognizer.verb).to eq(:post)
    end
  end

  describe '#pattern' do
    let(:app) do
      bob = Class.new(Eldr::App)
      bob.get '/', proc { [200, {}, ['']] }
      bob
    end
    let(:recognizer) { described_class.new(app.routes) }

    it 'normalizes a blank PATH_INFO to /' do
      recognizer.env = { 'PATH_INFO' => '' }
      expect(recognizer.pattern).to eq('/')
    end

    it 'returns the PATH_INFO unchanged when it is non-blank' do
      recognizer.env = Rack::MockRequest.env_for('/cats', { method: :get })
      expect(recognizer.pattern).to eq('/cats')
    end
  end

  describe 'route ordering' do
    it 'returns matching routes sorted by order' do
      app = Class.new(Eldr::App)
      app.add(verb: :get, path: '/cats', handler: proc { [] }, order: 2)
      app.add(verb: :get, path: '/cats', handler: proc { [] }, order: 1)
      recognizer = described_class.new(app.routes)
      routes = recognizer.call(Rack::MockRequest.env_for('/cats', { method: :get }))
      expect(routes.map(&:order)).to eq([1, 2])
    end
  end
end
