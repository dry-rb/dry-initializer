module Dry
  # Declares arguments of the initializer (params and options)
  #
  # @api public
  #
  module Initializer

    require_relative "initializer/errors"
    require_relative "initializer/argument"
    require_relative "initializer/arguments"
    require_relative "initializer/builder"

    # Declares a plain argument
    #
    # @param [#to_sym] name
    #
    # @option options [Object]  :default The default value
    # @option options [#call]   :type    The type constraings via `dry-types`
    # @option options [Boolean] :reader (true)  Whether to define attr_reader
    # @option options [Boolean] :writer (false) Whether to define attr_writer
    #
    # @return [self] itself
    #
    def param(name, **options)
      arguments_builder.call(name, option: false, **options)
      self
    end

    # Declares a named argument
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, **options)
      arguments_builder.call(name, option: true, **options)
      self
    end

    # Builder for arguments
    #
    # @api private
    #
    def arguments_builder
      @arguments_builder ||= begin
        builder = Builder.new
        include builder.mixin
        builder
      end
    end

    def inherited(klass)
      klass.instance_variable_set(:@arguments_builder, arguments_builder)
    end
  end
end
