# -*- encoding: utf-8 -*-
require_relative 'lib/eldr/version'

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

  s.required_ruby_version = '>= 3.1'

  s.add_dependency 'rack',       '~> 3.0'
  s.add_dependency 'mustermann', '~> 1.1'
  s.add_dependency 'fast_blank', '~> 1.0'

  s.add_development_dependency 'rake',      '~> 13.0'
  s.add_development_dependency 'rspec',     '~> 3.13'
  s.add_development_dependency 'rubocop',   '~> 1.69'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.add_development_dependency 'rack-test', '~> 2.1'
  s.add_development_dependency 'rackup',    '~> 2.2'
  s.add_development_dependency 'webrick',   '~> 1.8'
  s.add_development_dependency 'tilt',      '~> 2.9'
  s.add_development_dependency 'slim',      '~> 5.0'
  s.add_development_dependency 'simplecov', '~> 1.1'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
