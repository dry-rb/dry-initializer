module Dry::Initializer
  # A simple structure describes an argument (either param, or option)
  #
  # @api private
  #
  class Argument
    include Errors

    UNDEFINED = Object.new.freeze

    # @!attribute [r] option
    # @return [Boolean]
    #   Whether this is an option, or param of the initializer
    attr_reader :option

    # @!attribute [r] name
    # @return [Symbol] the name of the argument
    attr_reader :name

    # @!attribute [r] default
    # @return [Boolean] whether the argument has a default value
    attr_reader :default

    # @!attribute [r] default_value
    # @return [Object] the default value of the argument
    attr_reader :default_value

    # @!attribute [r] type
    # @return [Class, nil] a type constraint
    attr_reader :type

    # @!attribute [r] reader
    # @return [Boolean] whether an attribute reader is defined for the argument
    attr_reader :reader

    def initialize(name, option:, reader: true, **options)
      @name   = name.to_sym
      @option = option
      @reader = reader
      assign_default_value(options)
      assign_type(options)
    end

    def ==(other)
      other.name == name
    end

    def signature
      case [option, default]
      when [false, false] then name
      when [false, true]  then "#{name} = Dry::Initializer::Argument::UNDEFINED"
      when [true, false]  then "#{name}:"
      else
        "#{name}: Dry::Initializer::Argument::UNDEFINED"
      end
    end

    def assignment
      "@#{name} = #{name}"
    end

    def default_assignment
      "@#{name} = instance_eval(&__arguments__[:#{name}].default_value)" \
      " if #{name} == Dry::Initializer::Argument::UNDEFINED"
    end

    def type_constraint
      "__arguments__[:#{name}].type.call(@#{name})"
    end

    private

    def assign_default_value(options)
      @default = options.key? :default
      return unless @default

      @default_value = options[:default]
      return if Proc === @default_value

      fail InvalidDefaultValueError.new(@default_value)
    end

    def assign_type(options)
      return unless options.key? :type

      type = options[:type]
      type = plain_type_to_proc(type) if Module === type
      fail InvalidTypeError.new(type) unless type.respond_to? :call
      @type = type
    end

    def plain_type_to_proc(type)
      proc { |value| fail TypeError.new(type, value) unless type === value }
    end
  end
end
