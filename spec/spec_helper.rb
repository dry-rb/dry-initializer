# frozen_string_literal: true

require_relative "support/coverage"

require "dry/initializer"

begin
  require "pry"
rescue LoadError
  nil
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Prepare the Test namespace for constants defined in specs
  config.around(:each) do |example|
    Test = Class.new(Module)
    example.run
    Object.send :remove_const, :Test
  end

  config.warnings = true
end
