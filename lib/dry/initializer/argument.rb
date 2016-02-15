module Dry::Initializer
  # A simple structure describes an argument (either a parameter, or an option)
  #
  # @api private
  #
  class Argument
    include Errors

    UNDEFINED = Object.new.freeze

    # @!attribute [r] option
    # @return [Boolean]
    #   Whether this is an option (a named arg) or a parameter (a regular arg)
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
    # @return [#[], nil] a type constraint
    attr_reader :type

    def initialize(name, options = {})
      @name   = name.to_sym
      @option = !!options[:option]
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
      "@#{name} = __arguments__[:#{name}].default_value.call" \
      " if #{name} == Dry::Initializer::Argument::UNDEFINED"
    end

    def type_constraint
      "__arguments__[:#{name}].type.call(@#{name})"
    end

    private

    def assign_default_value(options)
      @default = options.key? :default
      return unless @default

      value = options[:default]
      @default_value = (Proc === value) ? value : proc { value }
    end

    def assign_type(options)
      return unless options.key? :type

      type = options[:type]
      @type = \
        if type.is_a? Module
          plain_type_to_proc(type)
        elsif type.respond_to?(:call)
          type
        else
          fail InvalidTypeError.new(type)
        end
    end

    def plain_type_to_proc(type)
      proc { |value| fail TypeError.new(type, value) unless type === value }
    end
  end
end
