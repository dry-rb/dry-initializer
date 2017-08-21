module Dry
  module Initializer
    # rubocop: disable Style/ConstantName
    Mixin = self # for backward compatibility
    # rubocop: enable Style/ConstantName
    UNDEFINED = Object.new.freeze

    require_relative "initializer/config"
    require_relative "initializer/extension"
    require_relative "initializer/definition"
    require_relative "initializer/param"
    require_relative "initializer/option"
    require_relative "initializer/instance"
    require_relative "initializer/utils"
    require_relative "initializer/validator"

    class << self
      include Extension
      include Utils

      def [](**settings)
        Module.new.tap do |mod|
          mod.extend Extension
          mod.include self
          mod.settings = settings
        end
      end
    end

    # Enumerable collection of definitions for params and options
    #
    # @return [Dry::Initializer::Definition]
    #
    def dry_initializer
      @dry_initializer ||= Config.new
    end

    # @!method param(name, type, opts)
    # Adds or redefines a parameter
    #
    # @param  [name]
    # @param  [type]
    # @return [self] itself
    #
    def param(*args)
      definition = Param.new(dry_initializer, *args)
      dry_initializer.param(definition)
      Validator.call(self)
      definition.define_reader(self)
    end

    # @!method option(name, type, opts)
    # Adds or redefines an option
    #
    # @param  [name]
    # @param  [type]
    # @return [self] itself
    #
    def option(*args)
      definition = Option.new(dry_initializer, *args)
      dry_initializer.option(definition)
      definition.define_reader(self)
    end

    private

    def inherited(klass)
      klass.__send__ :instance_variable_set,
                     :@dry_initializer,
                     Config.new(dry_initializer)
      super
    end
  end
end
