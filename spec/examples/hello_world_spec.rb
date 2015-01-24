describe 'HelloWorldExample' do
  let(:app) do
    path = File.expand_path("../../examples/hello_world.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'returns hello world' do
      response = rt.get '/'
      expect(response.body).to eq('Hello World!')
    end
  end
end
