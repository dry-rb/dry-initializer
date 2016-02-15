module Dry
  # Declares the arguments (parameters) and attributes, along with initializer
  # of the current class
  module Initializer

    require_relative "initializer/errors"
    require_relative "initializer/argument"
    require_relative "initializer/arguments"
    require_relative "initializer/builder"

    # Declares a <plain> argument (parameter) with name and options
    #
    # @param [#to_sym] name
    #
    # @option options [Object] :default The default value
    # @option options [#call]  :type    The type constraings via `dry-types`
    #
    # @return [self] itself
    #
    def argument(name, **options)
      arguments_builder.call(name, option: false, **options)
      self
    end
    alias_method :parameter, :argument

    # Declares named argument (attribute) with name and options
    #
    # @param  (see #argument)
    # @option (see #argument)
    # @return (see #argument)
    #
    def option(name, **options)
      arguments_builder.call(name, option: true, **options)
      self
    end
    alias_method :attribute, :option

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
  end
end
