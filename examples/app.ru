class ExampleApp < Eldr::App
  class NotFound < StandardError
    def call(env)
      [404, {}, ['']]
    end
  end
  attr_accessor :cats

  before :before do
    @thing1 = "Thing1"
  end

  before do
    @thing2 = "Thing2"
  end

  after :cats do
    @cats == 'Cats!'
  end

  get '/posts' do |params|
    Rack::Response.new "posts", 200
  end

  post '/posts' do
    Rack::Response.new "posts", 201
  end

  put '/posts' do
    Rack::Response.new "posts", 200
  end

  delete '/posts' do
    Rack::Response.new "posts", 201
  end

  get '/deferred' do
    throw :pass
  end

  get '/deferred' do
    Rack::Response.new "Deferred!", 200
  end

  get '/raises-an-error' do
    raise NotFound, 'Not Found'
  end

  get '/state' do
    @state = 1 + @state.to_i
    [200, {}, [@state]]
  end

  get '/state-2' do
    [200, {}, [@state ||= 0]]
  end

  get '/before', name: :before do
    [200, {}, [@thing1]]
  end

  get '/before-all', name: :before do
    [200, {}, [@thing2]]
  end

  get '/after' do
    [200, {}, ["Cats!"]]
  end

  get '/posts/:id' do
    [200, {}, [params['id']]]
  end
end

run ExampleApp
