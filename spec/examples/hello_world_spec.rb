# frozen_string_literal: true

RSpec.describe 'HelloWorldExample' do
  let(:app) do
    load_example_app('../examples/hello_world.ru')
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /' do
    it 'returns hello world' do
      response = rt.get '/'
      expect(response.body).to eq('Hello World!')
    end
  end
end
