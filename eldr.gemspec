# -*- encoding: utf-8 -*-
require File.expand_path('../lib/eldr/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eldr'
  s.version     = Eldr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['K-2052']
  s.email       = ['k@2052.me']
  s.homepage    = 'https://github.com/eldr-rb/eldr'
  s.summary     = 'A minimal framework that lights a fire in your development'
  s.description = 'A minimal framework that lights a fire in your development.
                   Built close to Rack and the metal.'
  s.licenses    = ['MIT']

  s.required_rubygems_version = '~> 2.0'
  s.required_ruby_version     = '~> 2.0'
  s.rubyforge_project         = 'eldr'

  s.add_dependency 'rack',       '~> 1.5'
  s.add_dependency 'mustermann', '0.4.0'
  s.add_dependency 'fast_blank', '0.0.2'

  s.add_development_dependency 'bundler',   '~> 1.7'
  s.add_development_dependency 'rake',      '10.4.2'
  s.add_development_dependency 'rspec',     '3.1.0'
  s.add_development_dependency 'rubocop',   '0.28.0'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'tilt',      '2.0.1'
  s.add_development_dependency 'slim',      '3.0.1'
  s.add_development_dependency 'coveralls', '~> 0.7'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
