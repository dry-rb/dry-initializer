#
# Prepares the variable name of a parameter or an option.
#
module Dry::Initializer::Dispatchers::PrepareIvar
  module_function

  def call(target:, **options)
    ivar = "@#{target}".delete('?').to_sym

    { target: target, ivar: ivar, **options }
  end
end
