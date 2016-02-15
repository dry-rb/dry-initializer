Bundler.require(:benchmarks)

require "dry-initializer"
class NoOptsTest
  extend Dry::Initializer

  parameter :foo
  option :bar
end

class DefaultsTest
  extend Dry::Initializer

  parameter :foo, default: "FOO"
  option    :bar, default: "BAR"
end

class TypesTest
  extend Dry::Initializer

  parameter :foo, type: String
  option    :bar, type: String
end

class DefaultsAndTypesTest
  extend Dry::Initializer

  parameter :foo, type: String, default: "FOO"
  option    :bar, type: String, default: "BAR"
end

puts "Benchmark for various options"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("no opts") do
    NoOptsTest.new "foo", bar: "bar"
  end

  x.report("with defaults") do
    DefaultsTest.new "foo", bar: "bar"
  end

  x.report("with types") do
    TypesTest.new "foo", bar: "bar"
  end

  x.report("with defaults and types") do
    DefaultsAndTypesTest.new "foo", bar: "bar"
  end

  x.compare!
end
