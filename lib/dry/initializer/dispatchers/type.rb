#
# Prepares the `:type` option
#
module Dry::Initializer::Dispatchers::Type
  extend self

  def call(type: nil, **options)
    type = callable! type
    check_arity! type

    { type: type, **options }
  end

  private

  def callable!(type)
    return unless type
    return type if type.respond_to?(:call)
    return callable(type.to_proc) if type.respond_to?(:to_proc)

    invalid!(type)
  end

  def check_arity!(type)
    return unless type

    arity = type.method(:call).arity.to_i.abs
    return if [1, 2].include? arity

    invalid!(type)
  end

  def invalid!(type)
    raise TypeError, "The type of #{type.inspect} should be" \
                     " either convertable to proc with 1..2 argument," \
                     " or respond to #call with 1..2 arguments."
  end
end
