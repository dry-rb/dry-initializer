require_relative "scope"

module Dry::Initializer
  # Class-level DSL for the initializer
  module Mixin
    # Declares a plain argument
    #
    # @param [#to_sym] name
    #
    # @option options [Object]  :default The default value
    # @option options [#call]   :type    The type constraings via `dry-types`
    # @option options [Boolean] :reader (true) Whether to define attr_reader
    #
    # @return [self] itself
    #
    def param(name, **options)
      @initializer_builder = \
        initializer_builder.define(name, option: false, **options)
      initializer_builder.call(self)
    end

    # Declares a named argument
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, **options)
      @initializer_builder = \
        initializer_builder.define(name, option: true, **options)
      initializer_builder.call(self)
    end

    # Declares arguments (params and options) with default settings
    #
    # @param  [Hash] settings Shared settings
    # @param  [Proc] block    Definitions for params and options
    # @return [self]
    #
    def using(**settings, &block)
      Scope.new(self, settings).instance_eval(&block)
      self
    end

    # Adds new plugin to the builder
    #
    # @param  [Dry::Initializer::Plugins::Base] plugin
    # @return [self] itself
    #
    def register_initializer_plugin(plugin)
      @initializer_builder = initializer_builder.register(plugin)
      initializer_builder.call(self)
    end

    # Makes initializer tolerant to unknown options
    #
    # @return [self] itself
    #
    def tolerant_to_unknown_options
      warn <<-MESSAGE.gsub(/ +\|/, "")
        |[DEPRECATION] Helper method `tolerant_to_unknown_options` was deprecated,
        |and will be removed in v0.9.0.
        |If any `option` was defined, the initializer becomes tolerant to all the others.
        |This is necessary to support "special" names in options like `option :end`.
        |It forbids options only when no one was declared explicitly.
      MESSAGE
    end

    # Makes initializer intolerant to unknown options
    #
    # @return [self] itself
    #
    def intolerant_to_unknown_options
      warn <<-MESSAGE.gsub(/ +\|/, "")
        |[DEPRECATION] Helper method `intolerant_to_unknown_options` was deprecated.
        |and will be removed in v0.9.0.
        |If any `option` was defined, the initializer becomes tolerant to all the others.
        |This is necessary to support "special" names in options like `option :end`.
        |It forbids options only when no one was declared explicitly.
      MESSAGE
    end

    private

    def initializer_builder
      @initializer_builder ||= Builder.new
    end

    def inherited(klass)
      klass.instance_variable_set :@initializer_builder, initializer_builder.dup
    end
  end
end
