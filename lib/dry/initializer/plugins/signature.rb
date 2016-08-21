module Dry::Initializer::Plugins
  # Plugin builds a chunk of code for the initializer's signature:
  #
  # @example
  #   Signature.call(:user, option: true)
  #   # => "user:"
  #
  #   Signature.call(:user, default: -> { nil })
  #   # => "user = Dry::Initializer::UNDEFINED"
  #
  class Signature < Base
    def param?
      settings[:option] != true
    end

    def default?
      settings.key? :default
    end

    def optional?
      default? || settings.key?(:optional)
    end

    def call
      case [param?, optional?]
      when [true, false]  then name.to_s
      when [false, false] then "#{name}:"
      when [true, true]   then "#{name} = #{undefined}"
      when [false, true]  then "#{name}: #{undefined}"
      end
    end

    private

    def undefined
      @undefined ||= "Dry::Initializer::UNDEFINED"
    end
  end
end
