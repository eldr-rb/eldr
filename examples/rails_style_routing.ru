$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class Cats
  def index env
    Rack::Response.new "Hello from all the Cats!"
  end
end

class RailsStyle < Eldr::App
  get '/cats', to: 'Cats#index'
end

run RailsStyle
