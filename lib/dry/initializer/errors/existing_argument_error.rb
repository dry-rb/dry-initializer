module Dry::Initializer::Errors
  class ExistingArgumentError < SyntaxError
    def initialize(name)
      super "the argument '#{name}' is already defined"
    end
  end
end
