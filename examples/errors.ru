$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class ErrorResponse < StandardError
  def call(env)
    Rack::Response.new message, 500
  end
end

class ErrorsExample < Eldr::App
  get '/' do
    raise ErrorResponse, "Bad Data"
  end
end

run ErrorsExample
