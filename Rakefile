require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new :default

namespace :benchmark do
  desc "Runs benchmarks for plain params"
  task :plain_params do
    system "ruby benchmarks/plain_params.rb"
  end

  desc "Runs benchmarks for plain options"
  task :plain_options do
    system "ruby benchmarks/plain_options.rb"
  end

  desc "Runs benchmarks for value coercion"
  task :with_coercion do
    system "ruby benchmarks/with_coercion.rb"
  end

  desc "Runs benchmarks with defaults"
  task :with_defaults do
    system "ruby benchmarks/with_defaults.rb"
  end

  desc "Runs benchmarks with defaults and coercion"
  task :with_defaults_and_coercion do
    system "ruby benchmarks/defaults_and_coercion.rb"
  end

  desc "Runs benchmarks for several defaults"
  task :compare_several_defaults do
    system "ruby benchmarks/several_defaults.rb"
  end
end

desc "Runs all benchmarks"
task benchmark: %i[
  benchmark:plain_params
  benchmark:plain_options
  benchmark:with_coercion
  benchmark:with_defaults
  benchmark:with_defaults_and_coercion
  benchmark:compare_several_defaults
]

namespace :profile do
  def profile(name, execution, &definition)
    require "dry-initializer"
    require "ruby-prof"
    require "fileutils"

    definition.call
    result = RubyProf.profile do
      1_000.times { execution.call }
    end

    FileUtils.mkdir_p "./tmp"

    FileUtils.touch "./tmp/#{name}.dot"
    File.open("./tmp/#{name}.dot", "w+") do |output|
      RubyProf::DotPrinter.new(result).print(output, min_percent: 0)
    end

    FileUtils.touch "./tmp/#{name}.html"
    File.open("./tmp/#{name}.html", "w+") do |output|
      RubyProf::CallStackPrinter.new(result).print(output, min_percent: 0)
    end

    system "dot -Tpng ./tmp/#{name}.dot > ./tmp/#{name}.png"
  end

  desc "Profiles initialization with required param and option"
  task :required do
    profile("required", -> { User.new :Andy, email: "andy@example.com" }) do
      class User
        extend Dry::Initializer
        param  :name
        option :email
      end
    end
  end

  desc "Profiles initialization with default param and option"
  task :defaults do
    profile("defaults", -> { User.new }) do
      class User
        extend Dry::Initializer
        param  :name,  default: -> { :Andy }
        option :email, default: -> { "andy@example.com" }
      end
    end
  end

  desc "Profiles initialization with coerced param and option"
  task :coercion do
    profile("coercion", -> { User.new :Andy, email: :"andy@example.com" }) do
      class User
        extend Dry::Initializer
        param  :name,  proc(&:to_s)
        option :email, proc(&:to_s)
      end
    end
  end

  desc "Profiles initialization with coerced defaults of param and option"
  task :default_coercion do
    profile("default_coercion", -> { User.new }) do
      class User
        extend Dry::Initializer
        param  :name,  proc(&:to_s), default: -> { :Andy }
        option :email, proc(&:to_s), default: -> { :"andy@example.com" }
      end
    end
  end
end

desc "Makes all profiling at once"
task profile: %i[
  profile:required
  profile:defaults
  profile:coercion
  profile:default_coercion
]
