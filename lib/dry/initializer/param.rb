module Dry::Initializer
  class Param < Attribute
    # part of __initializer__ definition
    def initializer_signature
      optional ? "#{target} = Dry::Initializer::UNDEFINED" : target
    end

    # parts of __initalizer__
    def presetter; end

    def safe_setter
      "@#{target} = #{maybe_coerced}"
    end

    def fast_setter
      safe_setter
    end

    def postsetter; end

    # part of __defaults__
    def default_hash
      super :param
    end

    # part of __coercers__
    def coercer_hash
      super :param
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
      " instance_exec(&__defaults__[:param_#{target}]) :" \
      " #{target}"
    end
  end
end
