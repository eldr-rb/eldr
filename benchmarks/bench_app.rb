# frozen_string_literal: true

require_relative 'support'
require 'benchmark/ips'

app = BenchSupport.app
built = BenchSupport.built_app

static_env  = BenchSupport.env('/static')
params_env  = BenchSupport.env('/cats/42?foo=bar')
not_found_env = BenchSupport.env('/nope')

Benchmark.ips do |x|
  x.report('App.call (class) - static')  { BenchSupport::App.call(static_env.dup) }
  x.report('app#call! - static')         { app.call!(static_env.dup) }
  x.report('built app.call - static')    { built.call(static_env.dup) }
  x.report('app#call! - params')         { app.call!(params_env.dup) }
  x.report('app#call! - 404')            { app.call!(not_found_env.dup) }

  x.compare!
end
