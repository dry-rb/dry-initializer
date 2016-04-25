Bundler.require(:benchmarks)

class PlainRubyTest
  attr_reader :foo, :bar

  def initialize(foo:, bar:)
    @foo = foo
    @bar = bar
    fail TypeError unless String === @foo
    fail TypeError unless String === @bar
  end
end

require "dry-initializer"
class DryTest
  extend Dry::Initializer::Mixin

  option :foo, type: String
  option :bar, type: String
end

require "virtus"
class VirtusTest
  include Virtus.model

  attribute :foo, String
  attribute :bar, String
end

require "fast_attributes"
class FastAttributesTest
  extend FastAttributes

  define_attributes initialize: true do
    attribute :foo, String
    attribute :bar, String
  end
end

puts "Benchmark for instantiation with type constraints"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("plain Ruby") do
    PlainRubyTest.new foo: "FOO", bar: "BAR"
  end

  x.report("dry-initializer") do
    DryTest.new foo: "FOO", bar: "BAR"
  end

  x.report("virtus") do
    VirtusTest.new foo: "FOO", bar: "BAR"
  end

  x.report("fast_attributes") do
    FastAttributesTest.new foo: "FOO", bar: "BAR"
  end

  x.compare!
end
