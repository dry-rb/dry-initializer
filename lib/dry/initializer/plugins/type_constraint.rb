module Dry::Initializer::Plugins
  # Plugin builds either chunk of code for the #initializer,
  # or a proc for the ##__after_initialize__ callback.
  class TypeConstraint < Base
    def call
      return unless settings.key? :type
      dry_type_constraint || module_type_constraint || object_type_constraint
    end

    private

    def type
      @type ||= settings[:type]
    end

    def dry_type?
      type.class.ancestors.map(&:name).include? "Dry::Types::Builder"
    end

    def plain_type?
      Module === type
    end

    def module_type_constraint
      return unless plain_type?

      "fail #{TypeError}.new(:#{name}, #{type}, @#{name})" \
      " unless @#{name} == Dry::Initializer::UNDEFINED ||" \
      " #{type} === @#{name}"
    end

    def dry_type_constraint
      return unless dry_type?

      ivar = :"@#{name}"
      constraint = type

      lambda do |*|
        value = instance_variable_get(ivar)
        return if value == Dry::Initializer::UNDEFINED

        instance_variable_set ivar, constraint[value]
      end
    end

    def object_type_constraint
      ivar = :"@#{name}"
      constraint = type

      lambda do |*|
        value = instance_variable_get(ivar)
        return if value == Dry::Initializer::UNDEFINED

        fail TypeError.new(ivar, constraint, value) unless constraint === value
      end
    end
  end
end
