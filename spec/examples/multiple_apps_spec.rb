describe 'MultipleAppsExample' do
  let(:app) do
    path = File.expand_path("../../examples/multiple_apps.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'returns hello world' do
      response = rt.get '/'
      expect(response.body).to eq('Hello World EXAMPLE!')
    end
  end

  describe 'GET /cats' do
    it 'returns cats' do
      response = rt.get '/cats'
      expect(response.body).to eq('Hello Cats!')
    end
  end

  describe 'GET /dogs' do
    it 'returns dogs' do
      response = rt.get '/dogs'
      expect(response.body).to eq('Hello Dogs!')
    end
  end
end
