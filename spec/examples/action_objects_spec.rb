describe "ActionObjectsExample" do
  let(:app) do
    path = File.expand_path("../../examples/action_objects.ru", File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /cats/bob' do
    it 'returns bob' do
      response = rt.get '/cats/bob'
      expect(response.body).to eq('Found cat named Bob!')
    end
  end

end
