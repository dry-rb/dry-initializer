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
    def param(name, type = nil, **options)
      options[:type]   = type if type
      options[:option] = false
      @initializer_builder = initializer_builder.define(name, **options)
      initializer_builder.call(self)
    end

    # Declares a named argument
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, type = nil, **options)
      options[:type]   = type if type
      options[:option] = true
      @initializer_builder = initializer_builder.define(name, **options)
      initializer_builder.call(self)
    end

    # Declares arguments (params and options) with default settings
    #
    # @param  [Hash] settings Shared settings
    # @param  [Proc] block    Definitions for params and options
    # @return [self]
    #
    def using(**settings, &block)
      warn "[DEPRECATION] The method `using` will be removed in v0.10.0"
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

    private

    def initializer_builder
      @initializer_builder ||= Builder.new
    end

    def inherited(klass)
      klass.instance_variable_set :@initializer_builder, initializer_builder.dup
    end

    def self.extended(klass)
      klass.send(:initializer_builder).call(klass)
    end
  end
end
