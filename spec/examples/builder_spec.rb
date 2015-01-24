describe 'BuilderExample' do
  let(:app) do
    path = File.expand_path("../../examples/builder.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'does some counting using middleware' do
      expect(rt.get('/').body).to eq('1')
    end
  end
end
