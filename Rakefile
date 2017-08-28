require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new :default

load "lib/tasks/benchmark.rake"
load "lib/tasks/profile.rake"
