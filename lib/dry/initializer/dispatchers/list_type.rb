#
# Converts array types to the corresponding coercer
#
# In case of `param :foo, []`          it just wraps the input to array
# In case of `param :foo, [some_type]` it also applies the some_type
#                                      to every element of the array
#
module Dry::Initializer::Dispatchers::ListType
  extend self

  def call(type: nil, **options)
    type = list_type(type) if type.is_a?(Array)

    { type: type, **options }
  end

  private

  def list_type(type)
    type = type.first
    case arity(type)
    when 0 then proc { |input| wrap(input) }
    when 1 then proc { |input| wrap(input).map { |item| type.call(item) } }
    else proc { |input, obj| wrap(input).map { |item| type.call(item, obj) } }
    end
  end

  def arity(type)
    type ? type.method(:call).arity.to_i.abs : 0
  end

  def wrap(input)
    return []           if input.nil?
    return input        if input.is_a?(Array)
    return [input]      if input.is_a?(Hash)
    return input.to_ary if input.respond_to?(:to_ary)
    return input.to_a   if input.respond_to?(:to_a)

    [input]
  end
end
