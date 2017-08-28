Bundler.require(:benchmarks)

require "dry-initializer"
class DryTest
  extend Dry::Initializer[undefined: false]

  option :foo
  option :bar
end

class DryTestUndefined
  extend Dry::Initializer

  option :foo
  option :bar
end

class PlainRubyTest
  attr_reader :foo, :bar

  def initialize(options = {})
    @foo = options[:foo]
    @bar = options[:bar]
  end
end

require "anima"
class AnimaTest
  include Anima.new(:foo, :bar)
end

require "kwattr"
class KwattrTest
  kwattr :foo, :bar
end

puts "Benchmark for instantiation with plain options"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("plain Ruby") do
    PlainRubyTest.new foo: "FOO", bar: "BAR"
  end

  x.report("dry-initializer") do
    DryTest.new foo: "FOO", bar: "BAR"
  end

  x.report("dry-initializer (with UNDEFINED)") do
    DryTestUndefined.new foo: "FOO", bar: "BAR"
  end

  x.report("anima") do
    AnimaTest.new foo: "FOO", bar: "BAR"
  end

  x.report("kwattr") do
    KwattrTest.new foo: "FOO", bar: "BAR"
  end

  x.compare!
end
