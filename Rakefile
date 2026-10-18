# frozen_string_literal: true

require 'rbconfig'
require 'fileutils'
require 'tmpdir'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new(:yard)

desc 'Alias for `yard`'
task doc: :yard

desc 'Run the benchmark suite'
task :bench do
  Dir[File.expand_path('benchmarks/bench_*.rb', __dir__)].each do |file|
    sh RbConfig.ruby, '-Ilib', file
  end
end

task default: %i[rubocop spec]

namespace :wiki do
  # Copies docs/wiki/*.md into a checkout of the GitHub wiki repo and pushes
  # it. This is intentionally a manual release step: the wiki is a separate
  # git repository and the default GITHUB_TOKEN is not able to push it, so the
  # account running this needs SSH or PAT credentials. Override the remote
  # with WIKI_REMOTE=... if needed.
  desc 'Publish docs/wiki to the GitHub wiki (requires push credentials)'
  task :publish do
    remote  = ENV.fetch('WIKI_REMOTE', 'git@github.com:eldr-rb/eldr.wiki.git')
    sources = Dir[File.expand_path('docs/wiki/*.md', __dir__)]
    abort 'no wiki sources found in docs/wiki' if sources.empty?

    Dir.mktmpdir('eldr-wiki') do |tmp|
      dir = File.join(tmp, 'wiki')
      sh 'git', 'clone', remote, dir
      FileUtils.cp(sources, dir)
      Dir.chdir(dir) do
        sh 'git', 'add', '--all'
        sh 'git', 'commit', '-m', 'Sync wiki from docs/wiki'
        sh 'git', 'push', 'origin', 'master'
      end
    end
  end
end
