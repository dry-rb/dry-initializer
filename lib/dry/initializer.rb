# Namespace for gems in a dry-rb community
module Dry
  #
  # DSL for declaring params and options of class initializers
  #
  module Initializer
    # Singleton for unassigned values
    UNDEFINED = Object.new.freeze

    require_relative "initializer/dsl"
    require_relative "initializer/definition"
    require_relative "initializer/builders"
    require_relative "initializer/config"
    require_relative "initializer/mixin"

    # Adds methods [.[]] and [.define]
    extend DSL

    # Gem-related configuration
    # @return [Dry::Initializer::Config]
    def dry_initializer
      @dry_initializer ||= Config.new(self)
    end

    # Adds or redefines a parameter of [#dry_initializer]
    # @param  [Symbol]       name
    # @param  [#call, nil]   coercer (nil)
    # @option opts [#call]   :type
    # @option opts [Proc]    :default
    # @option opts [Boolean] :optional
    # @option opts [Symbol]  :as
    # @option opts [true, false, :protected, :public, :private] :reader
    # @return [self] itself
    def param(name, type = nil, **opts)
      dry_initializer.param(name, type, opts)
      self
    end

    # Adds or redefines an option of [#dry_initializer]
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    def option(name, type = nil, **opts)
      dry_initializer.option(name, type, opts)
      self
    end

    private

    def inherited(klass)
      super
      klass.dry_initializer
    end
  end
end
