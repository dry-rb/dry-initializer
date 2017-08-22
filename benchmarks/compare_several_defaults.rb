Bundler.require(:benchmarks)

require "dry-initializer"
class WithoutDefaults
  extend Dry::Initializer

  param :foo
  param :bar
  param :baz
end

class WithOneDefault
  extend Dry::Initializer

  param :foo
  param :bar
  param :baz, default: proc { "BAZ" }
end

class WithTwoDefaults
  extend Dry::Initializer

  param :foo
  param :bar, default: proc { "BAR" }
  param :baz, default: proc { "BAZ" }
end

class WithThreeDefaults
  extend Dry::Initializer

  param :foo, default: proc { "FOO" }
  param :bar, default: proc { "BAR" }
  param :baz, default: proc { "BAZ" }
end

puts "Benchmark for various options"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("without defaults") do
    WithoutDefaults.new "FOO", "BAR", "BAZ"
  end

  x.report("with 0 of 1 default used") do
    WithOneDefault.new "FOO", "BAR", "BAZ"
  end

  x.report("with 1 of 1 default used") do
    WithOneDefault.new "FOO", "BAR"
  end

  x.report("with 0 of 2 defaults used") do
    WithTwoDefaults.new "FOO", "BAR", "BAZ"
  end

  x.report("with 1 of 2 defaults used") do
    WithTwoDefaults.new "FOO", "BAR"
  end

  x.report("with 2 of 2 defaults used") do
    WithTwoDefaults.new "FOO"
  end

  x.report("with 0 of 3 defaults used") do
    WithThreeDefaults.new "FOO", "BAR", "BAZ"
  end

  x.report("with 1 of 3 defaults used") do
    WithThreeDefaults.new "FOO", "BAR"
  end

  x.report("with 2 of 3 defaults used") do
    WithThreeDefaults.new "FOO"
  end

  x.report("with 3 of 3 defaults used") do
    WithThreeDefaults.new
  end

  x.compare!
end
