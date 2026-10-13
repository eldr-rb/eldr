# frozen_string_literal: true

RSpec.describe 'RenderingTemplatesExample' do
  let(:app) do
    load_example_app('../examples/rendering_templates.ru')
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /cats' do
    it 'returns a template' do
      response = rt.get '/cats'
      file_path = File.expand_path('../../examples/views/cats.slim', File.dirname(__FILE__))
      expect(response.body).to eq Tilt.new(file_path).render
    end
  end

  describe 'GET /no-template' do
    it 'returns 404' do
      response = rt.get '/no-template'
      expect(response.status).to eq(404)
      expect(response.body).to eq('Template Not Found')
    end
  end
end
