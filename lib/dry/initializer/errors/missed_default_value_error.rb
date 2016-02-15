module Dry::Initializer::Errors
  class MissedDefaultValueError < SyntaxError
    def initialize(name)
      super "you should set a default value for the '#{name}'"
    end
  end
end
