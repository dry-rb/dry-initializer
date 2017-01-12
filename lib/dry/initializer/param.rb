module Dry::Initializer
  class Param < Attribute
    # part of __initializer__ definition
    def initializer_signature
      required ? target : "#{target} = Dry::Initializer::UNDEFINED"
    end

    # part of __initializer__ body
    def initializer_presetter; end

    # part of __initializer__ body
    def initializer_setter
      "@#{target} = #{maybe_coerced}"
    end

    # part of __defaults__
    def default_hash
      default ? { :"param_#{target}" => default } : {}
    end

    # part of __coercers__
    def coercer_hash
      coercer ? { :"param_#{target}" => coercer } : {}
    end

    private

    def initialize(*args, **options)
      fail ArgumentError.new("Do not rename params") if options.key? :as
      super
    end

    def maybe_coerced
      return maybe_default unless coercer
      "__coercers__[:param_#{target}].call(#{maybe_default})"
    end

    def maybe_default
      "#{target}#{default_part}"
    end

    def default_part
      return unless default
      " == Dry::Initializer::UNDEFINED ?" \
      " instance_eval(&__defaults__[:param_#{target}]) :" \
      " #{target}"
    end
  end
end
