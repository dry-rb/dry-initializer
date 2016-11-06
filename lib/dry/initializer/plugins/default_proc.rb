module Dry::Initializer::Plugins
  # Builds a block to be evaluated by initializer (__after_initialize__)
  # to assign a default value to the argument
  class DefaultProc < Base
    def call
      return unless default

      ivar = :"@#{rename}"
      default_proc = default

      proc do
        if instance_variable_get(ivar) == Dry::Initializer::UNDEFINED
          instance_variable_set ivar, instance_eval(&default_proc)
        end
      end
    end

    private

    def default
      return unless settings.key? :default

      @default ||= settings[:default].tap do |value|
        fail DefaultValueError.new(name, value) unless Proc === value
      end
    end
  end
end
