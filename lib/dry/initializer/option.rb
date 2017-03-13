module Dry::Initializer
  class Option < Attribute
    # part of __initializer__ definition
    def initializer_signature
      "**__options__"
    end

    # parts of __initalizer__
    def presetter
      "@#{target} = #{undefined}" if dispensable? && @undefined
    end

    def safe_setter
      "@#{target} = #{safe_coerced}#{maybe_optional}"
    end

    def fast_setter
      return safe_setter unless dispensable?
      "@#{target} = __options__.key?(:'#{source}')" \
                  " ? #{safe_coerced}" \
                  " : #{undefined}"
    end

    def postsetter
      "@__options__[:#{target}] = @#{target}" \
      " unless @#{target} == #{undefined}"
    end

    # part of __defaults__
    def default_hash
      super :option
    end

    # part of __coercers__
    def coercer_hash
      super :option
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
        " { instance_exec(&__defaults__[:'option_#{source}']) }"
      elsif !optional
        " { raise ArgumentError, \"option :'#{source}' is required\" }"
      end
    end
  end
end
