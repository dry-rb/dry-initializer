module Dry::Initializer
  class ParamsOrderError < SyntaxError
    def initialize(required, optional)
      super "Optional param '#{optional}'" \
            " should not preceed required '#{required}'"
    end
  end
end
