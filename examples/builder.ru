$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class SimpleCounterMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['eldr.simple_counter'] ||= 0
    env['eldr.simple_counter'] += 1
    @app.call(env)
  end
end

class BuilderExample < Eldr::App
  use SimpleCounterMiddleware

  get '/' do |env|
    Rack::Response.new env['eldr.simple_counter'].to_s
  end
end

run BuilderExample
