Bundler.require(:benchmarks)

require "dry-initializer"

class ParamDefaults
  extend Dry::Initializer

  param :foo, default: proc { "FOO" }
  param :bar, default: proc { "BAR" }
  param :baz, default: proc { "BAZ" }
end

class OptionDefaults
  extend Dry::Initializer

  option :foo, default: proc { "FOO" }
  option :bar, default: proc { "BAR" }
  option :baz, default: proc { "BAZ" }
end

puts "Benchmark for param's vs. option's defaults"

Benchmark.ips do |x|
  x.config time: 15, warmup: 10

  x.report("param's defaults") do
    ParamDefaults.new
  end

  x.report("option's defaults") do
    OptionDefaults.new
  end

  x.compare!
end
