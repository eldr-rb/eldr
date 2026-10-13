# frozen_string_literal: true

RSpec.describe 'ActionObjectsExample' do
  let(:app) do
    load_example_app('../examples/action_objects.ru')
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
