module Dry::Initializer::Plugins
  # Plugin builds a chunk of code for the initializer's signature:
  #
  # @example
  #   Signature.call(:user)
  #   # => "user"
  #
  #   Signature.call(:user, default: -> { nil })
  #   # => "user = Dry::Initializer::UNDEFINED"
  #
  #   Signature.call(:user, option: true)
  #   # => nil
  #
  class Signature < Base
    def param?
      settings[:option] != true
    end

    def required?
      !settings.key?(:default) && !settings[:optional]
    end

    def call
      return unless param?
      required? ? name.to_s : "#{name} = Dry::Initializer::UNDEFINED"
    end
  end
end
