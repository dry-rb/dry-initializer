# Namespace for gems in a dry-rb community
module Dry
  #
  # DSL for declaring params and options of class initializers
  #
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

      # Returns a version of the module with custom settings
      #
      # @option settings [Boolean] undefined
      #   If unassigned params and options should be treated different from nil
      # @return [Dry::Initializer]
      #
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
    # @param  [Symbol]       name
    # @param  [#call, nil]   coercer (nil)
    # @option opts [#call]   :type
    # @option opts [Proc]    :default
    # @option opts [Boolean] :optional
    # @option opts [Symbol]  :as
    # @option opts [true, false, :protected, :public, :private] :reader
    # @return [self] itself
    #
    def param(name, type = nil, **opts)
      definition = Param.new(dry_initializer, name, type, opts)
      dry_initializer.send :add_param, definition
      definition.define_reader(self)
      self
    end

    # @!method option(name, type, opts)
    # Adds or redefines an option of [#dry_initializer]
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, type = nil, **opts)
      definition = Option.new(dry_initializer, name, type, opts)
      dry_initializer.send :add_option, definition
      definition.define_reader(self)
      self
    end
  end
end
