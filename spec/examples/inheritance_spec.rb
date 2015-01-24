describe 'InheritedApp' do
  let(:app) do
    path = File.expand_path("../../examples/inheritance.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'counts using counter middleware' do
      response = rt.get '/'
      expect(response.body).to eq('1')
    end
  end

  describe '.configuration#bob' do
    it 'returns "what about him?"' do
      expect(app.configuration.bob).to eq('what about him?')
    end
  end
end
