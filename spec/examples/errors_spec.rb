describe 'ErrorsExample' do
  let(:app) do
    path = File.expand_path("../../examples/errors.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'returns an error' do
      response = rt.get '/'
      expect(response.body).to eq('Bad Data')
      expect(response.status).to eq(500)
    end
  end
end
