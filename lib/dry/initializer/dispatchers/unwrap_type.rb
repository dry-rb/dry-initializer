#
# Looks at the `:type` option and counts how many nested arrays
# it contains around either nil or a callable value.
#
# The counted number is preserved in the `:wrap` virtual option
# used by the [WrapType] dispatcher.
#
module Dry::Initializer::Dispatchers::UnwrapType
  extend self

  def call(type: nil, wrap: 0, **options)
    type, wrap = unwrap(type, 0)

    { type: type, wrap: wrap, **options }
  end

  private

  def unwrap(type, count)
    type.is_a?(Array) ? unwrap(type.first, count + 1) : [type, count]
  end
end
