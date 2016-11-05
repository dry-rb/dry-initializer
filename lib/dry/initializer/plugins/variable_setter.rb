module Dry::Initializer::Plugins
  # Plugin builds a code for variable setter:
  #
  # @example
  #   VariableSetter.call(:user, option: false)
  #   # => "@user = user"
  #
  #   VariableSetter.call(:user, option: true)
  #   # => "@user = __options__.fetch(:user)"
  #
  #   VariableSetter.call(:user, option: true, optional: true)
  #   # => "@user = __options__.fetch(:user, Dry::Initializer::UNDEFINED)"
  #
  class VariableSetter < Base
    def param?
      settings[:option] != true
    end

    def required?
      !settings.key?(:default) && !settings[:optional]
    end

    def call
      return "@#{name} = #{name}" if param?
      return "@#{name} = __options__.fetch(:#{name})" if required?
      "@#{name} = __options__.fetch(:#{name}, Dry::Initializer::UNDEFINED)"
    end
  end
end
