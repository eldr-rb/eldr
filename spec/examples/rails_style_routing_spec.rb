describe 'RailsStyleRoutingExample' do
  let(:app) do
    path = File.expand_path("../../examples/rails_style_routing.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /cats' do
    it 'returns a greeting from cats' do
      response = rt.get '/cats'
      expect(response.body).to eq('Hello from all the Cats!')
    end
  end
end
