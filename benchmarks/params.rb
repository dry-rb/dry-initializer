Bundler.require(:benchmarks)

class PlainRubyTest
  attr_reader :foo, :bar

  def initialize(foo, bar)
    @foo = foo
    @bar = bar
  end
end

StructTest = Struct.new(:foo, :bar)

require "dry-initializer"
class DryTest
  extend Dry::Initializer::Mixin

  param :foo
  param :bar
end

require "concord"
class ConcordTest
  include Concord.new(:foo, :bar)
end

require "values"
ValueTest = Value.new(:foo, :bar)

require "value_struct"
ValueStructTest = ValueStruct.new(:foo, :bar)

require "attr_extras"
class AttrExtrasText
  attr_initialize :foo, :bar
  attr_reader :foo, :bar
end

puts "Benchmark for instantiation of plain params"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("plain Ruby") do
    PlainRubyTest.new "FOO", "BAR"
  end

  x.report("Core Struct") do
    StructTest.new "FOO", "BAR"
  end

  x.report("values") do
    ValueTest.new "FOO", "BAR"
  end

  x.report("value_struct") do
    ValueStructTest.new "FOO", "BAR"
  end

  x.report("dry-initializer") do
    DryTest.new "FOO", "BAR"
  end

  x.report("concord") do
    ConcordTest.new "FOO", "BAR"
  end

  x.report("attr_extras") do
    AttrExtrasText.new "FOO", "BAR"
  end

  x.compare!
end
