module Dry::Initializer
  # Namespace for code plugins builders
  module Plugins
    require_relative "plugins/base"
    require_relative "plugins/default_proc"
    require_relative "plugins/signature"
    require_relative "plugins/type_constraint"
    require_relative "plugins/variable_setter"
  end
end
