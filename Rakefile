require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new :default

desc "Runs benchmarks without options"
task :without_options do
  system "ruby benchmarks/without_options.rb"
end

desc "Runs benchmarks with types"
task :with_types do
  system "ruby benchmarks/with_types.rb"
end

desc "Runs benchmarks with defaults"
task :with_defaults do
  system "ruby benchmarks/with_defaults.rb"
end

desc "Runs benchmarks with types and defaults"
task :with_types_and_defaults do
  system "ruby benchmarks/with_types_and_defaults.rb"
end

desc "Runs benchmarks for plain parameters"
task :params do
  system "ruby benchmarks/params.rb"
end

desc "Runs benchmarks various opts"
task :options do
  system "ruby benchmarks/options.rb"
end
