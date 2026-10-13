# frozen_string_literal: true

RSpec.describe 'CascadeExample' do
  let(:app) do
    load_example_app('../examples/cascade.ru')
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'returns the 200 from HelloWorld after NotFound did not match' do
      response = rt.get '/'
      expect(response.body).to eq('Hello from the cascade!')
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /missing' do
    it 'returns 404 for unmatched paths (the cascade returns the last app response)' do
      response = rt.get '/missing'
      expect(response.status).to eq(404)
    end
  end
end
