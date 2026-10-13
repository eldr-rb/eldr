# frozen_string_literal: true

RSpec.describe 'ErrorsExample' do
  let(:app) do
    load_example_app('../examples/errors.ru')
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
