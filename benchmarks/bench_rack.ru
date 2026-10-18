# frozen_string_literal: true

# A rackup file for external benchmarking tools (ab, wrk, bench-micro):
#
#   bundle exec rackup benchmarks/bench_rack.ru
#
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'eldr'

class BenchRackApp < Eldr::App
  get '/' do
    [200, { 'content-type' => 'text/plain' }, ['ok']]
  end

  get '/cats/:id' do
    [200, { 'content-type' => 'text/plain' }, [params['id']]]
  end
end

run BenchRackApp
