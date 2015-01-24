$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class HelloWorldExample < Eldr::App
  get '/' do
    Rack::Response.new "Hello World EXAMPLE!"
  end
end

class CatsExample < Eldr::App
  get '/' do
    Rack::Response.new "Hello Cats!"
  end
end

class DogsExample < Eldr::App
  get '/', proc { Rack::Response.new "Hello Dogs!" }
end

map '/' do
  run HelloWorldExample
end

map '/cats' do
  run CatsExample
end

map '/dogs' do
  run DogsExample
end
