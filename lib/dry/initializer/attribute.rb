module Dry::Initializer
  # Contains definitions for a single attribute, and builds its parts of mixin
  class Attribute
    class << self
      # Collection of additional dispatchers for method options
      #
      # @example Enhance the gem by adding :coercer alias for type
      #   Dry::Initializer::Attribute.dispatchers << -> (string: nil, **op) do
      #     op[:type] = proc(&:to_s) if string
      #     op
      #   end
      #
      #   class User
      #     extend Dry::Initializer
      #     param :name, string: true # same as `type: proc(&:to_s)`
      #   end
      #
      def dispatchers
        @@dispatchers ||= []
      end

      def new(source, coercer = nil, **options)
        options[:source] = source
        options[:target] = options.delete(:as) || source
        options[:type] ||= coercer
        params = dispatchers.inject(options) { |h, m| m.call(h) }

        super(params)
      end

      def param(*args)
        Param.new(*args)
      end

      def option(*args)
        Option.new(*args)
      end
    end

    attr_reader :source, :target, :coercer, :default, :optional, :reader

    def initialize(options)
      @source         = options[:source]
      @target         = options[:target]
      @coercer        = options[:type]
      @default        = options[:default]
      @optional       = !!(options[:optional] || @default)
      @reader         = options.fetch(:reader, :public)
      @hide_undefined = options.fetch(:hide_undefined, true)
      validate
    end

    def ==(other)
      source == other.source
    end

    # definition for the getter method
    def getter
      return unless reader
      command = %w(private protected).include?(reader.to_s) ? reader : :public

      <<-RUBY.gsub(/^ *\|/, "")
        |undef_method :#{target} if method_defined?(:#{target}) ||
        |                           protected_method_defined?(:#{target}) ||
        |                           private_method_defined?(:#{target})
        |#{reader_definition}
        |#{command} :#{target}
      RUBY
    end

    private

    def validate
      validate_target
      validate_default
      validate_coercer
    end

    def undefined
      "Dry::Initializer::UNDEFINED"
    end

    def reader_definition
      if @hide_undefined
        "def #{target}; @#{target} unless @#{target} == #{undefined}; end"
      else
        "attr_reader :#{target}"
      end
    end

    def validate_target
      return if target =~ /\A\w+\Z/
      fail ArgumentError.new("Invalid name '#{target}' for the target variable")
    end

    def validate_default
      return if default.nil? || default.is_a?(Proc)
      fail DefaultValueError.new(source, default)
    end

    def validate_coercer
      return if coercer.nil? || coercer.respond_to?(:call)
      fail TypeConstraintError.new(source, coercer)
    end

    def default_hash(type)
      default ? { :"#{type}_#{source}" => default } : {}
    end

    def coercer_hash(type)
      return {} unless coercer
      value = proc { |v| v == Dry::Initializer::UNDEFINED ? v : coercer.(v) }
      { :"#{type}_#{source}" => value }
    end
  end
end
