# frozen_string_literal: true

require_relative "support/coverage"

require "dry/initializer"

begin
  require "pry"
rescue LoadError
  nil
end

SPEC_ROOT = Pathname(__dir__)

Dir.glob(SPEC_ROOT.join("support", "**", "*.rb")).each do |file|
  require_relative file
end

RSpec.configure do |config|
  config.order = :random
  config.run_all_when_everything_filtered = true

  # Prepare the Test namespace for constants defined in specs
  config.around(:each) do |example|
    Test = Class.new(Module)
    example.run
    Object.send :remove_const, :Test
  end
end
