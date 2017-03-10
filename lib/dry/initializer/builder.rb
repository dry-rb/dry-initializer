module Dry::Initializer
  class Builder
    def param(*args, **opts)
      @params = insert @params, Attribute.param(*args, **@config.merge(opts))
      validate_collections
    end

    def option(*args, **opts)
      @options = insert @options, Attribute.option(*args, **@config.merge(opts))
      validate_collections
    end

    def call(mixin)
      clear_method(mixin, :__defaults__)
      clear_method(mixin, :__coercers__)
      clear_method(mixin, :__initialize__)

      defaults = send(:defaults)
      coercers = send(:coercers)

      mixin.send(:define_method, :__defaults__) { defaults }
      mixin.send(:define_method, :__coercers__) { coercers }
      mixin.class_eval(code, __FILE__, __LINE__ + 1)
    end

    private

    def initialize(**config)
      @config  = config
      @params  = []
      @options = []
    end

    def insert(collection, new_item)
      index = collection.index(new_item) || collection.count
      collection.dup.tap { |list| list[index] = new_item }
    end

    def clear_method(mixin, name)
      mixin.send(:undef_method, name) if mixin.private_method_defined? name
    end

    def code
      <<-RUBY.gsub(/^ +\|/, "")
        |def __initialize__(#{initializer_signatures})
        |  @__options__ = {}
        |#{initializer_presetters}
        |#{initializer_setters}
        |#{initializer_postsetters}
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

    def duplications
      attributes.group_by(&:target)
                .reject { |_, val| val.count == 1 }
                .keys
    end

    def initializer_signatures
      sig = @params.map(&:initializer_signature).compact.uniq
      sig << (sig.any? && @options.any? ? "**__options__" : "__options__ = {}")
      sig.join(", ")
    end

    def initializer_presetters
      dups = duplications
      attributes.map { |a| "  #{a.presetter}" if dups.include? a.target }
                .compact.uniq.join("\n")
    end

    def initializer_setters
      dups = duplications
      attributes.map do |a|
        dups.include?(a.target) ? "  #{a.safe_setter}" : "  #{a.fast_setter}"
      end.compact.uniq.join("\n")
    end

    def initializer_postsetters
      attributes.map { |a| "  #{a.postsetter}" }.compact.uniq.join("\n")
    end

    def defined_options
      if @options.any?
        keys = @options.map(&:target).join(" ")
        "__options__.select { |key| %i(#{keys}).include? key }"
      else
        "{}"
      end
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

    def validate_collections
      optional_param = nil

      @params.each do |param|
        if param.optional
          optional_param = param.source if param.optional
        elsif optional_param
          fail ParamsOrderError.new(param.source, optional_param)
        end
      end

      self
    end
  end
end
