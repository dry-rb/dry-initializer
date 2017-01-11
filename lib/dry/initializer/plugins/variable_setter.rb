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
      return false if settings.key? :default
      settings[:required] || settings[:optional] == false
    end

    def call
      return "@#{name} = #{name}" if param?
      key = ":\"#{name}\""
      return "@#{rename} = __options__.fetch(#{key})" if required?
      "@#{rename} = __options__.fetch(#{key}, Dry::Initializer::UNDEFINED)"
    end
  end
end
