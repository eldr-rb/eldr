describe "ExampleApp" do
  it 'does not pollute the base class with routes' do
    expect(Eldr::App.routes[:get].length).to eq(0)
  end

  let(:app) do
    path = File.expand_path("../../examples/app.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /posts' do
    it 'returns a 200 status' do
      response = rt.get '/posts'
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /posts' do
    it 'returns a 201 status' do
      response = rt.post '/posts'
      expect(response.status).to eq(201)
    end
  end

  describe 'PUT /posts' do
    it 'returns a 200 status' do
      response = rt.put '/posts'
      expect(response.status).to eq(200)
    end
  end

  describe 'DELETE /posts' do
    it 'returns a 201 status' do
      response = rt.delete '/posts'
      expect(response.status).to eq(201)
    end
  end

  describe 'GET /state' do
    it 'does not maintain state between requests' do
      response = rt.get '/state'
      expect(response.body).to eq('1')

      response = rt.get '/state'
      expect(response.body).to eq('1')
    end
  end

  describe 'before and after filters GET /' do
    it 'comes out in the correct order' do
      order = []

      cats = Class.new(Eldr::App)
      cats.after { order << :after }
      cats.before { order << :before }

      cats.get'/' do
        order << :action
        Rack::Response.new("Cats!", 200)
      end

      app_a = cats.new

      app_b = Rack::Builder.new do
        run app_a
      end

      rt2 = Rack::Test::Session.new(app_b)
      rt2.get '/'
      expect(order).to eq([:before, :action, :after])
    end
  end

  describe 'GET /raises-an-error' do
    it 'returns a 404 status' do
      response = rt.get '/raises-an-error'
      expect(response.status).to eq(404)
    end
  end

  describe 'GET /defer' do
    it 'defers a route' do
      response = rt.get '/deferred'
      expect(response.body).to eq('Deferred!')
    end
  end

  describe 'GET /posts/:id' do
    it 'returns a posts id' do
      response = rt.get '/posts/bob'
      expect(response.body).to eq('bob')
    end
  end
end
