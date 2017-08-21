module Dry::Initializer
  #
  # @private
  # @abstract
  #
  # Base class for parameter or option definitions
  # Defines methods to add corresponding reader to the class,
  # and build value of instance attribute.
  #
  class Definition
    attr_reader :config, :source, :target, :type, :default, :reader

    def undefined
      config.undefined
    end

    def ivar
      @ivar ||= :"@#{target}"
    end

    def ==(other)
      other.instance_of?(self.class) && (other.source == source)
    end

    def define_reader(klass)
      klass.send :undef_method, target if klass.method_defined? target
      return unless reader

      if undefined
        klass.send :define_method, target do
          ivar  = :"@#{__method__}"
          value = instance_variable_get(ivar) if instance_variable_defined? ivar
          (value == Dry::Initializer::UNDEFINED) ? nil : value
        end
      else
        klass.send :attr_reader, target
      end

      klass.send reader, target
    end

    def value(instance, value)
      coerce substitute(instance, value)
    end

    private

    def initialize(config, source, coercer = nil, **options)
      @config  = config
      @source  = source.to_sym
      @target  = check_target options.fetch(:as, source).to_sym
      @type    = check_type(coercer || options[:type])
      @reader  = prepare_reader options.fetch(:reader, true)
      @default = check_default options[:default]
      @default ||= proc { config.undefined } if options[:optional]
    end

    def check_target(value)
      return value if value[/\w+[?]?/]
      raise ArgumentError, "Invalid variable name :#{target}"
    end

    def check_type(value)
      return if value.nil?
      arity = value.respond_to?(:call) ? value.method(:call).arity : 0
      return value unless arity.zero? || arity > 1
      raise TypeError,
            "type of #{inspect} should respond to #call with one argument"
    end

    def check_default(value)
      return if value.nil?
      return value if value.is_a?(Proc) && value.arity < 1
      raise TypeError,
            "default value of #{inspect} should be a proc without params"
    end

    def prepare_reader(value)
      case value.to_s
      when "", "false" then false
      when "private"   then :private
      when "protected" then :protected
      else :public
      end
    end

    def substitute(instance, value)
      return value unless value == undefined
      raise ArgumentError, "#{inspect} should be defined" unless default
      instance.instance_exec(&default)
    end

    def coerce(value)
      return value if value == undefined
      return value unless type
      type.call(value)
    end
  end
end
