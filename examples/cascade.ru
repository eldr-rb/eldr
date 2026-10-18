$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eldr'

# Eldr::Cascade chains apps together, returning the first response that is
# not a "caught" status (default 404 / 405). It is a Rack::Cascade
# replacement that works with Rack::Response objects.
#
# Pass a custom catch list as the second argument, e.g.
#   Eldr::Cascade.new([A, B], [403, 404, 405])
class CascadeHelloWorld < Eldr::App
  get '/', proc { [200, { 'content-type' => 'text/plain' }, ['Hello from the cascade!']] }
end

class CascadeNotFound < Eldr::App
  get '/missing', proc { [404, { 'content-type' => 'text/plain' }, ['missed']] }
end

run Eldr::Cascade.new([CascadeNotFound, CascadeHelloWorld])