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
    attr_reader :option, :null, :source, :target, :ivar,
                :type, :optional, :default, :reader,
                :desc

    def options
      {
        as:       target,
        type:     type,
        optional: optional,
        default:  default,
        reader:   reader,
        desc:     desc
      }.reject { |_, value| value.nil? }
    end

    def name
      @name ||= (option ? "option" : "parameter") << " '#{source}'"
    end
    alias to_s    name
    alias to_str  name
    alias inspect name

    def ==(other)
      other.instance_of?(self.class) && (other.source == source)
    end

    def code
      Builders::Reader[self]
    end

    def inch
      @inch ||= (option ? "@option" : "@param ").tap do |text|
        text << " [Object]"
        text << (option ? " :#{source}" : " #{source}")
        text << (optional ? " (optional)" : " (required)")
        text << " #{desc}" if desc
      end
    end

    private

    def initialize(option, null, source, coercer = nil, **options)
      @option   = !!option
      @null     = null
      @source   = source.to_sym
      @target   = check_target options.fetch(:as, source).to_sym
      @ivar     = :"@#{target}"
      @type     = check_type(coercer || options[:type])
      @reader   = prepare_reader options.fetch(:reader, true)
      @default  = check_default options[:default]
      @optional = options.fetch(:optional, @default)
      @desc     = options[:desc]&.to_s&.capitalize
    end

    def check_source(value)
      if RESERVED.include? value
        raise ArgumentError, "Name #{value} is reserved by dry-initializer gem"
      end

      unless option || value[ATTRIBUTE]
        raise ArgumentError, "Invalid parameter name :'#{value}'"
      end

      value
    end

    def check_target(value)
      return value if value[ATTRIBUTE]
      raise ArgumentError, "Invalid variable name :'#{value}'"
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

    ATTRIBUTE = /\A\w+\z/
    RESERVED  = %i[
      __dry_initializer_options__
      __dry_initializer_config__
      __dry_initializer_value__
      __dry_initializer_definition__
      __dry_initializer_initializer__
    ].freeze
  end
end
