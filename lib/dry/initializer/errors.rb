module Dry::Initializer
  # Collection of gem-specific exceptions
  module Errors

    require_relative "errors/existing_argument_error"
    require_relative "errors/invalid_default_value_error"
    require_relative "errors/invalid_type_error"
    require_relative "errors/key_error"
    require_relative "errors/missed_default_value_error"
    require_relative "errors/type_error"

  end
end
