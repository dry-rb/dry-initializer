Bundler.require(:benchmarks)

require "dry-initializer"
class NoOptsTest
  extend Dry::Initializer

  param  :foo
  option :bar
end

class DefaultsTest
  extend Dry::Initializer

  param  :foo, default: proc { "FOO" }
  option :bar, default: proc { "BAR" }
end

class TypesTest
  extend Dry::Initializer

  param  :foo, type: String
  option :bar, type: String
end

class DefaultsAndTypesTest
  extend Dry::Initializer

  param  :foo, type: String, default: proc { "FOO" }
  option :bar, type: String, default: proc { "BAR" }
end

puts "Benchmark for various options"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("no opts") do
    NoOptsTest.new "foo", bar: "bar"
  end

  x.report("with defaults") do
    DefaultsTest.new
  end

  x.report("with types") do
    TypesTest.new "foo", bar: "bar"
  end

  x.report("with defaults and types") do
    DefaultsAndTypesTest.new
  end

  x.compare!
end
