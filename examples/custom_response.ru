$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class Response
  attr_accessor :status, :headers, :body

  def initialize(body, status=200, headers={})
    @body, @status, @headers = body, status, headers
  end

  def to_a
    [@status, @headers, [@body]]
  end
  alias_method :to_ary, :to_a
end

class CustomResponseExample < Eldr::App
  get '/' do
    Response.new("Hello World Custom!")
  end
end

run CustomResponseExample
