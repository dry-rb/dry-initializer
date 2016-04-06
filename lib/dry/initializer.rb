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
    # @option options [Boolean] :reader (true) Whether to define attr_reader
    #
    # @return [self] itself
    #
    def param(name, **options)
      arguments_builder.define_initializer(name, option: false, **options)
      self
    end

    # Declares a named argument
    #
    # @param  (see #param)
    # @option (see #param)
    # @return (see #param)
    #
    def option(name, **options)
      arguments_builder.define_initializer(name, option: true, **options)
      self
    end

    # Declares a hash with attr_hash to read/write variables
    #
    # @param [#to_s] name
    # @param [Array<#to_s>] keys
    # @option options [Boolean] :reader (true)
    #
    # @return [self] itself
    #
    def attr_hash(name, *keys, reader: true)
      arguments_builder.define_attributes_reader(name, keys) if reader
      self
    end

    private

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
