describe Eldr::App do
  it 'has methods for all the http verbs' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      expect(Eldr::App.respond_to? verb.downcase.to_sym).to eq(true)
    end
  end

  describe '.inherited' do
    it 'inherits middleware' do
      bob = Class.new(Eldr::App)
      middleware = Class.new
      expect(bob.builder.middleware.length).to eq(0)

      bob.use middleware
      expect(bob.builder.middleware.length).to eq(1)

      # TODO Check that is is the actual class we wanted
      inherited = Class.new(bob)
      expect(inherited.builder.middleware.length).to eq(1)
    end

    it 'inherits configuration' do
      bob = Class.new(Eldr::App)
      bob.set(:bob, 'what about him?')

      inherited = Class.new(bob)
      expect(inherited.configuration.bob).to eq('what about him?')
    end
  end

  describe '.new' do
    it 'returns a new instance of Eldr::Builder' do
      expect(Eldr::App.new).to be_instance_of Eldr::Builder
    end
  end

  describe '.set' do
    it 'sets configurations values' do
      bob = Class.new(Eldr::App)
      bob.set(:bob, 'what about him?')

      expect(bob.config.bob).to eq('what about him?')
    end
  end

  describe '.before' do
    it 'adds a before filter' do
      bob = Class.new(Eldr::App)
      bob.before {}
      bob.before(:cats) { }
      expect(bob.before_filters[:all].length).to eq(1)
      expect(bob.before_filters[:cats].length).to eq(1)
    end
  end

  describe '.after' do
    it 'adds an before filter' do
      bob = Class.new(Eldr::App)
      bob.after {}
      bob.after(:cats) { }
      expect(bob.after_filters[:all].length).to eq(1)
      expect(bob.after_filters[:cats].length).to eq(1)
    end
  end

  describe '.add' do
    it 'adds a route to self.routes' do
      bob = Class.new(Eldr::App)
      expect(bob.routes[:get].length).to eq(0)
      bob.add(verb: :get, path: '/', handler: proc {})
      expect(bob.routes[:get].length).to eq(1)
    end
  end

  describe '.call' do
    let(:env) do
      Rack::MockRequest.env_for('/', {:method => :get})
    end

    it 'creates a new builder instance runs in and returns a response' do
      bob = Class.new(Eldr::App)
      expect(bob.call(env)).to eq([404, {}, [""]])
    end
  end

  describe '#recognize' do
    let(:resp_proc) { proc { [200, {}, ['Hello Bob!']] } }
    subject(:app) do
      bob = Class.new(Eldr::App)
      bob.get '/cats', resp_proc
      bob._new
    end

    let(:env) do
      Rack::MockRequest.env_for('/cats', {:method => :get})
    end

    it 'recognizes and returns a route for a given pattern' do
      expect(app.recognize(env).first.handler).to eq(resp_proc)
    end
  end

  describe '#call' do
    subject(:app) do
      Class.new(Eldr::App)
    end

    let(:env) do
      Rack::MockRequest.env_for('/cats', {:method => :get})
    end

    it 'duplicates and runs call! on the duplicate' do
      expect_any_instance_of(app).to receive(:call!)
      app._new.call(env)
    end
  end

  describe '#call!' do
    subject(:app) do
      bob = Class.new(Eldr::App)
      bob.get '/cats/:id', name: :cats do
        [200, {}, ['Hello Bob!']]
      end

      bob.get '/defer' do
        throw :pass
      end

      bob.get '/defer' do
        [200, {}, ['Hello From Deferred!']]
      end

      class Error < StandardError
        def call(_env)
          [500, {}, ['']]
        end
      end

      bob.get '/error' do
        raise Error
      end

      bob._new
    end

    let(:env) do
      Rack::MockRequest.env_for('/cats/bob', {:method => :get})
    end

    let(:env_defer) do
      Rack::MockRequest.env_for('/defer', {:method => :get})
    end

    let(:env_error) do
      Rack::MockRequest.env_for('/error', {:method => :get})
    end

    let(:env_error) do
      Rack::MockRequest.env_for('/error', {:method => :get})
    end

    let(:env_not_found) do
      Rack::MockRequest.env_for('/god', {:method => :get})
    end

    it 'sets eldr.route' do
      app.call!(env)
      expect(app.env['eldr.route'].name).to eq(:cats)
    end

    it 'sets eldr.params' do
      app.call!(env)
      expect(app.env['eldr.params']['id']).to eq('bob')
    end

    context 'when passing/deferring' do
      it 'calls the next matching route' do
        expect(app.call!(env_defer).to_a[2].first).to eq('Hello From Deferred!')
      end
    end

    context 'when raising an error' do
      it 'catches the error and returns a response' do
        expect(app.call!(env_error).first).to eq(500)
      end
    end

    context 'when route does not exist' do
      it 'returns a 404' do
        expect(app.call!(env_not_found).first).to eq(404)
      end
    end
  end
end
