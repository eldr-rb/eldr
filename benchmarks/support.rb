# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'eldr'
require 'rack/mock_request'

# Shared fixtures for the benchmark scripts.
#
# The app is deliberately small but representative: a static route, a
# parameterized route, a few extra routes to make the linear scan non-trivial,
# and a path that matches nothing (the 404 path).
module BenchSupport
  class App < Eldr::App
    get '/' do
      [200, { 'content-type' => 'text/plain' }, ['root']]
    end

    get '/cats/:id' do
      [200, { 'content-type' => 'text/plain' }, ["cat #{params['id']}"]]
    end

    get '/static' do
      [200, { 'content-type' => 'text/plain' }, ['static']]
    end

    post '/cats' do
      [201, { 'content-type' => 'text/plain' }, ['created']]
    end

    get '/a' do
      [200, {}, ['a']]
    end

    get '/b' do
      [200, {}, ['b']]
    end

    get '/c' do
      [200, {}, ['c']]
    end
  end

  module_function

  def env(path, method: :get)
    Rack::MockRequest.env_for(path, method: method)
  end

  def app
    App._new
  end

  def built_app
    App.new # ensures the builder has been wired up with an app instance
    App.builder.to_app
  end
end
