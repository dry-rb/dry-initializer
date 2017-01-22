module Dry::Initializer
  class Builder
    def param(source, *args)
      index = @params.index { |param| param.source == source.to_s }

      if index
        new_param = Param.new(source, index, *args)
        @params   = params.dup.tap { |list| list[index] = new_param }
      else
        new_param = Param.new(source, @params.count, *args)
        @params  += [new_param]
      end

      validate_collection
      self
    end

    def option(source, *args)
      index = @options.index { |option| option.source == source.to_s }

      if index
        new_option = Option.new(source, index, *args)
        @options   = options.dup.tap { |list| list[index] = new_option }
      else
        new_option = Option.new(source, @options.count, *args)
        @options  += [new_option]
      end

      validate_collection
      self
    end

    def call(mixin)
      defaults = send(:defaults)
      coercers = send(:coercers)
      mixin.send(:define_method, :__defaults__) { defaults }
      mixin.send(:define_method, :__coercers__) { coercers }
      mixin.class_eval(code, __FILE__, __LINE__ + 1)
    end

    private

    def initialize
      @params  = []
      @options = []
    end

    def code
      <<-RUBY.gsub(/^ +\|/, "")
        |def __initialize__(#{initializer_signatures})
        |  @__options__ = __options__
        |#{initializer_presetters}
        |#{initializer_setters}
        |end
        |private :__initialize__
        |private :__defaults__
        |private :__coercers__
        |
        |#{getters}
      RUBY
    end

    def attributes
      @params + @options
    end

    def initializer_signatures
      sig = @params.map(&:initializer_signature).compact.uniq
      sig << (@options.any? ? "**__options__" : "__options__ = {}")
      sig.join(", ")
    end

    def initializer_presetters
      attributes.map(&:initializer_presetter)
                .compact
                .uniq
                .map { |line| "  #{line}" }
                .join("\n")
    end

    def initializer_setters
      attributes.map(&:initializer_setter)
                .compact
                .uniq
                .map { |text| text.lines.map { |line| "  #{line}" }.join }
                .join("\n")
    end

    def getters
      attributes.map(&:getter).compact.uniq.join("\n")
    end

    def defaults
      attributes.map(&:default_hash).reduce({}, :merge)
    end

    def coercers
      attributes.map(&:coercer_hash).reduce({}, :merge)
    end

    def validate_collection
      optional_param = nil
      @params.each do |param|
        if param.optional
          optional_param = param.source if param.optional
        elsif optional_param
          fail ParamsOrderError.new(param.source, optional_param)
        end
      end
    end
  end
end
