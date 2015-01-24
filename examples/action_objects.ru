$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class Show
  attr_accessor :env
  
  def helper_logic
    # do things here
  end

  def params
    env['eldr.params']
  end

  def call(env)
    @env = env

    helper_logic
    # @cat = Cat.find params[:id]
    Rack::Response.new "Found cat named #{params['name'].capitalize}!"
  end
end

class CatsController < Eldr::App
  get '/cats/:name', Show.new
end

run CatsController.new
