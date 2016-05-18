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
      @initializer_builder = initializer_builder
                             .reload(self, name, option: false, **options)
      self
    end

    # Declares a named argument
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, **options)
      @initializer_builder = initializer_builder
                             .reload(self, name, option: true, **options)
      self
    end

    # @private
    def initializer_builder
      @initializer_builder ||= Builder.new
    end

    # @private
    def inherited(klass)
      klass.instance_variable_set :@initializer_builder, initializer_builder.dup
    end
  end
end
