# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

task :default do
  Rake::Task['rubocop'].invoke
  Rake::Task['spec'].invoke
end
