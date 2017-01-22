module Dry::Initializer
  # Contains definitions for a single attribute, and builds its parts of mixin
  class Attribute
    attr_reader :source, :target, :coercer, :default, :optional, :reader

    # definition for the getter method
    def getter
      return unless reader
      command = %w(private protected).include?(reader.to_s) ? reader : :public

      <<-RUBY.gsub(/^ *\|/, "")
        |def #{target}
        |  @#{target} unless @#{target} == Dry::Initializer::UNDEFINED
        |end
        |#{command} :#{target}
      RUBY
    end

    private

    def initialize(source, coercer = nil, **options)
      @source   = source
      @target   = options.fetch(:as, source)
      @coercer  = coercer || options[:type]
      @reader   = options.fetch(:reader, :public)
      @default  = options[:default]
      @optional = !!(options[:optional] || @default)
      validate
    end

    def validate
      validate_target
      validate_default
      validate_coercer
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
  end
end
