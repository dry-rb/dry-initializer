module Dry::Initializer
  class ParamsOrderError < RuntimeError
    def initialize(required, optional)
      super "Optional param '#{optional}'" \
            " should not preceed required '#{required}'"
    end
  end
end
