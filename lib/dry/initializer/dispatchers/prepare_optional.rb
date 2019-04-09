#
# Defines whether an argument is optional
#
module Dry::Initializer::Dispatchers::PrepareOptional
  module_function

  def call(optional: nil, default: nil, required: nil, **options)
    optional ||= default
    optional &&= !required

    { optional: !!optional, default: default, **options }
  end
end
