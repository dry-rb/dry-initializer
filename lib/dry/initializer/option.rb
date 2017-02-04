module Dry::Initializer
  class Option < Attribute
    # part of __initializer__ definition
    def initializer_signature
      "**__options__"
    end

    # parts of __initalizer__
    def presetter
      "@#{target} = Dry::Initializer::UNDEFINED" if dispensable?
    end

    def safe_setter
      "@#{target} = #{safe_coerced}#{maybe_optional}"
    end

    def fast_setter
      return safe_setter unless dispensable?
      "@#{target} = __options__.key?(:'#{source}') ? #{safe_coerced} : " \
      "Dry::Initializer::UNDEFINED"
    end

    # part of __defaults__
    def default_hash
      default ? { :"option_#{source}" => default } : {}
    end

    # part of __coercers__
    def coercer_hash
      return {} unless coercer
      value = proc { |v| v == Dry::Initializer::UNDEFINED ? v : coercer.(v) }
      { :"option_#{source}" => value }
    end

    private

    def dispensable?
      optional && !default
    end

    def maybe_optional
      " if __options__.key? :'#{source}'" if dispensable?
    end

    def safe_coerced
      return safe_default unless coercer
      "__coercers__[:'option_#{source}'].call(#{safe_default})"
    end

    def safe_default
      "__options__.fetch(:'#{source}')#{default_part}"
    end

    def default_part
      if default
        " { instance_eval(&__defaults__[:'option_#{source}']) }"
      elsif !optional
        " { raise ArgumentError, \"option :'#{source}' is required\" }"
      end
    end
  end
end
