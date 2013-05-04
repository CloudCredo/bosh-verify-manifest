require 'bundler'
require 'rake/testtask'

task :default => [:test]

Bundler.setup
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end
