# frozen_string_literal: true

RSpec.describe 'BuilderExample' do
  let(:app) do
    load_example_app('../examples/builder.ru')
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
