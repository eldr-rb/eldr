$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

class HelloWorld < Eldr::App
  get '/', proc { [200, {'content-type' => 'txt'}, ['Hello World!']] }
end

run HelloWorld
