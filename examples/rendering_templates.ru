$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'
require 'tilt'
require 'slim'

module RenderingResponses
  class NotFound < StandardError
    def call(env)
      Rack::Response.new message, 404
    end
  end
end

module RenderingHelpers
  def render(path, resp_code=200)
    Rack::Response.new Tilt.new(find_template(path)).render(self), resp_code
  end

  def find_template(path)
    template = File.join(__dir__, 'views', path)
    raise RenderingResponses::NotFound, 'Template Not Found' unless File.exists? template
    template
  end
end

class RenderingTemplatesExample < Eldr::App
  include RenderingHelpers

  get '/cats' do
    render 'cats.slim'
  end

  get '/no-template' do
    render 'template.slim'
  end
end

run RenderingTemplatesExample
