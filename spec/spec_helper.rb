# frozen_string_literal: true

# Opt-in coverage via COVERAGE=1. SimpleCov must start before the code
# under test is required so that lib/ files are instrumented. The suite is
# kept at 100% line and branch coverage; the gate fails the run (exit 2)
# on any regression.
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    skip '/spec/'
    skip '/examples/'
    group 'lib', 'lib'
    enable_coverage :branch
    SimpleCov.minimum_coverage line: 100, branch: 100
  end
end

require 'rack/test'
require 'rack'
require_relative '../lib/eldr'

# Load shared spec support helpers.
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.pattern = '**{,/*/**}/*_spec.rb'
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  config.disable_monkey_patching!
  config.color_mode = :automatic
end
