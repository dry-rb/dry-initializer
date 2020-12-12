Bundler.require(:benchmarks)

require "dry-initializer"
class DryTest
  extend Dry::Initializer[undefined: false]

  option :foo, proc(&:to_s), default: -> { "FOO" }
  option :bar, proc(&:to_s), default: -> { "BAR" }
end

class DryTestUndefined
  extend Dry::Initializer

  option :foo, proc(&:to_s), default: -> { "FOO" }
  option :bar, proc(&:to_s), default: -> { "BAR" }
end

class PlainRubyTest
  attr_reader :foo, :bar

  def initialize(foo: "FOO", bar: "BAR")
    @foo = foo
    @bar = bar
    raise TypeError unless String === @foo
    raise TypeError unless String === @bar
  end
end

require "virtus"
class VirtusTest
  include Virtus.model

  attribute :foo, String, default: "FOO"
  attribute :bar, String, default: "BAR"
end

puts "Benchmark for instantiation with type constraints and default values"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("plain Ruby") do
    PlainRubyTest.new
  end

  x.report("dry-initializer") do
    DryTest.new
  end

  x.report("dry-initializer (with UNDEFINED)") do
    DryTest.new
  end

  x.report("virtus") do
    VirtusTest.new
  end

  x.compare!
end
