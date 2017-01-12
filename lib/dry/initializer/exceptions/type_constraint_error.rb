module Dry::Initializer
  class TypeConstraintError < TypeError
    def initialize(name, type)
      super "#{type} constraint for argument '#{name}' doesn't respond to #call"
    end
  end
end
