module Dry::Initializer::Plugins
  # Plugin builds either chunk of code for the #initializer,
  # or a proc for the ##__after_initialize__ callback.
  class TypeConstraint < Base
    def call
      return unless settings.key? :type

      type = settings[:type]
      fail TypeConstraintError.new(name, type) unless type.respond_to? :call

      ivar = :"@#{name}"
      lambda do |*|
        value = instance_variable_get(ivar)
        return if value == Dry::Initializer::UNDEFINED
        instance_variable_set ivar, type.call(value)
      end
    end
  end
end
