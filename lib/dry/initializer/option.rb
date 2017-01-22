module Dry::Initializer
  class Option < Attribute
    # part of __initializer__ definition
    def initializer_signature
      "**__options__"
    end

    # part of __initializer__ body
    def initializer_presetter
      "@#{target} = Dry::Initializer::UNDEFINED"
    end

    # part of __initializer__ body
    def initializer_setter
      "#{setter_part}#{maybe_optional}"
    end

    # part of __defaults__
    def default_hash
      default ? { :"option_#{source}" => default } : {}
    end

    # part of __coercers__
    def coercer_hash
      coercer ? { :"option_#{source}" => coercer } : {}
    end

    private

    def maybe_optional
      " if __options__.key? :'#{source}'" if optional && !default
    end

    def setter_part
      "@#{target} = #{maybe_coerced}"
    end

    def maybe_coerced
      return maybe_default unless coercer
      "__coercers__[:'option_#{source}'].call(#{maybe_default})"
    end

    def maybe_default
      "__options__.fetch(:'#{source}') { #{default_part} }"
    end

    def default_part
      if default
        "instance_eval(&__defaults__[:'option_#{source}'])"
      else
        "raise ArgumentError, \"option :'#{source}' is required\""
      end
    end
  end
end
