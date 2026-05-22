# frozen_string_literal: true

# Namespace for gems in a dry-rb community
module Dry
  #
  # DSL for declaring params and options of class initializers
  #
  module Initializer
    require_relative "initializer/undefined"
    require_relative "initializer/dsl"
    require_relative "initializer/definition"
    require_relative "initializer/builders"
    require_relative "initializer/config"
    require_relative "initializer/mixin"
    require_relative "initializer/dispatchers"

    # Adds methods [.[]] and [.define]
    extend DSL

    # Gem-related configuration
    # @return [Dry::Initializer::Config]
    def dry_initializer
      @dry_initializer ||= Config.new(self)
    end

    # Adds or redefines a parameter of [#dry_initializer]
    # @param  [Symbol]       name
    # @param  [#call, nil]   type (nil)
    # @option opts [Proc]    :default
    # @option opts [Boolean] :optional
    # @option opts [Symbol]  :as
    # @option opts [true, false, :protected, :public, :private] :reader
    # @yield block with nested definition
    # @return [self] itself
    def param(name, type = nil, **opts, &block)
      dry_initializer.param(name, type, **opts, &block)
      self
    end

    # Adds or redefines an option of [#dry_initializer]
    # @param  (see #param)
    # @option (see #param)
    # @yield  (see #param)
    # @return (see #param)
    def option(name, type = nil, **opts, &block)
      dry_initializer.option(name, type, **opts, &block)
      self
    end

    # Seal the initializer config: freeze the definitions, reject
    # further `param`/`option` calls, and (where supported) make the
    # config Ractor-shareable.
    # @see Dry::Initializer::Config#finalize
    # @return [self]
    def finalize
      dry_initializer.finalize
      self
    end

    private

    def inherited(klass)
      super
      config = Config.new(klass, null: dry_initializer.null)
      klass.define_singleton_method(:dry_initializer) { config }
    end

    require_relative "initializer/struct"
  end
end
