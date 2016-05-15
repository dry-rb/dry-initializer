module Dry::Initializer::Plugins
  # Plugin builds a code for variable setter:
  #
  # @example
  #   VariableSetter.call(:user, {}) # => "@user = user"
  #
  class VariableSetter < Base
    def call
      "@#{name} = #{name}"
    end
  end
end
