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
      @__initializer_builder__ = __initializer_builder__.define(name, **options)
      __initializer_builder__.call(__initializer_mixin__)
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
      @__initializer_builder__ = __initializer_builder__.define(name, **options)
      __initializer_builder__.call(__initializer_mixin__)
    end

    # Adds new plugin to the builder
    #
    # @param  [Dry::Initializer::Plugins::Base] plugin
    # @return [self] itself
    #
    def register_initializer_plugin(plugin)
      @__initializer_builder__ = __initializer_builder__.register(plugin)
      __initializer_builder__.call(__initializer_mixin__)
    end

    private

    def __initializer_mixin__
      @__initializer_mixin__ ||= Module.new do
        def initialize(*args)
          __initialize__(*args)
        end
      end
    end

    def __initializer_builder__
      @__initializer_builder__ ||= Builder.new
    end

    def inherited(klass)
      new_builder = __initializer_builder__.dup
      klass.instance_variable_set :@__initializer_builder__, new_builder

      new_mixin = Module.new
      new_builder.call(new_mixin)
      klass.instance_variable_set :@__initializer_mixin__, new_mixin
      klass.include new_mixin

      super
    end

    def self.extended(klass)
      super
      mixin = klass.send(:__initializer_mixin__)
      klass.send(:__initializer_builder__).call(mixin)
      klass.include mixin
    end
  end
end
