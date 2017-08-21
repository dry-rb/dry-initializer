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

    class << self
      include Extension

      def [](**settings)
        Module.new.tap do |mod|
          mod.extend Extension
          mod.include self
          mod.settings = settings
        end
      end
    end

    # Gem-related configuration
    #
    # @return [Dry::Initializer::Config]
    #
    def dry_initializer
      @dry_initializer ||= Config.new(self)
    end

    # @!method param(name, type, opts)
    # Adds or redefines a parameter of [#dry_initializer]
    #
    # @param  [name]
    # @param  [type]
    # @return [self] itself
    #
    def param(*args)
      definition = Param.new(dry_initializer, *args)
      dry_initializer.param(definition)
      definition.define_reader(self)
      self
    end

    # @!method option(name, type, opts)
    # Adds or redefines an option of [#dry_initializer]
    #
    # @param  [name]
    # @param  [type]
    # @return [self] itself
    #
    def option(*args)
      definition = Option.new(dry_initializer, *args)
      dry_initializer.option(definition)
      definition.define_reader(self)
      self
    end
  end
end
