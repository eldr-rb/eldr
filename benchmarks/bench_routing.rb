# frozen_string_literal: true

require_relative 'support'
require 'benchmark/ips'

recognizer = Eldr::Recognizer.new(BenchSupport::App.routes)

static_env = BenchSupport.env('/static')
params_env = BenchSupport.env('/cats/42')
not_found_env = BenchSupport.env('/nope')

def recognize(recognizer, env)
  recognizer.call(env)
rescue Eldr::Recognizer::NotFound
  []
end

Benchmark.ips do |x|
  x.report('recognizer - static') { recognize(recognizer, static_env) }
  x.report('recognizer - params') { recognize(recognizer, params_env) }
  x.report('recognizer - 404')    { recognize(recognizer, not_found_env) }

  x.compare!
end
