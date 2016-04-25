module Dry
  # Declares arguments of the initializer (params and options)
  #
  # @api public
  #
  module Initializer

    require_relative "initializer/errors"
    require_relative "initializer/argument"
    require_relative "initializer/arguments"
    require_relative "initializer/builder"
    require_relative "initializer/mixin"

  end
end
