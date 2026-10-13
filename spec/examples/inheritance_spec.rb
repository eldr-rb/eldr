# frozen_string_literal: true

RSpec.describe 'InheritedApp' do
  let(:app) do
    load_example_app('../examples/inheritance.ru')
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
      expect(load_raw_example_app('../examples/inheritance.ru').configuration.bob).to eq('what about him?')
    end
  end
end
