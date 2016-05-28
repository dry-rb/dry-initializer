module Dry::Initializer
  # Collection of gem-specific exceptions
  module Errors
    require_relative "errors/default_value_error"
    require_relative "errors/order_error"
    require_relative "errors/plugin_error"
    require_relative "errors/redefinition_error"
    require_relative "errors/type_constraint_error"
  end
end
