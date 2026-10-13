# frozen_string_literal: true

RSpec.describe 'RailsStyleRoutingExample' do
  let(:app) do
    load_example_app('../examples/rails_style_routing.ru')
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
