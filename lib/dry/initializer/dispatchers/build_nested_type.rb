#
# Prepare nested data type from a block
#
# @example
#   option :foo do
#     option :bar
#     option :qux
#   end
#
module Dry::Initializer::Dispatchers::BuildNestedType
  extend self

  # rubocop: disable Metrics/ParameterLists
  def call(parent:, source:, target:, type: nil, block: nil, **options)
    check_certainty!(source, type, block)
    type ||= build_nested_type(parent, target, block)
    { parent: parent, source: source, target: target, type: type, **options }
  end
  # rubocop: enable Metrics/ParameterLists

  private

  def check_certainty!(source, type, block)
    return unless type
    return unless block

    raise ArgumentError, <<~MESSAGE
      You should define coercer of values of argument '#{source}'
      either though the parameter/option, or via nested block, but not the both.
    MESSAGE
  end

  def check_name!(name, const_name)
    return unless const_name == ""

    raise ArgumentError, <<~MESSAGE
      The name of the argument '#{name}' cannot be used for nested struct.
      A proper name should start from a unicode letter.
    MESSAGE
  end

  def build_nested_type(parent, name, block)
    return unless block

    klass_name = full_name(parent, name)
    build_struct(klass_name, block)
  end

  def full_name(parent, name)
    const_name = name.to_s.split("_").compact.map(&:capitalize).join
    check_name! name, const_name
    "::#{parent.name}::#{const_name}"
  end

  def build_struct(klass_name, block)
    eval "class #{klass_name}; extend Dry::Initializer; end"
    klass = const_get(klass_name)
    klass.class_eval(&block)
    klass.singleton_class.send(:define_method, :call) { |opts| new(opts) }
    klass.singleton_class.send(:undef_method, :param)
    klass
  end
end
