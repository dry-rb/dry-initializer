# Dry::Initializer

DSL for building class initializer with params and options.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-initializer'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install dry-initializer
```

## Synopsis

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name, type: String
  param :type, default: 'customer'

  option :admin, default: false
end

user = User.new 'Vladimir', 'admin', admin: true
user.name  # => 'Vladimir'
user.type  # => 'admin'
user.admin # => true
```

This is pretty the same as:

```ruby
class User
  attr_reader :name, :type, :admin

  def initializer(name, type = 'customer', admin: false)
    @name  = name
    @type  = type
    @admin = admin

    fail TypeError unless String === @name
  end
end
```

### Params and Options

Use `param` to define plain argument:

```ruby
class User
  extend Dry::Initializer

  param :name
  param :email
end

user = User.new 'Andrew', 'andrew@email.com'
user.name  # => 'Andrew'
user.email # => 'andrew@email.com'
```

Use `option` to define named argument:

```ruby
class User
  extend Dry::Initializer

  option :name
  option :email
end

user = User.new email: 'andrew@email.com', name: 'Andrew'
user.name  # => 'Andrew'
user.email # => 'andrew@email.com'
```

All names should be unique:

```ruby
class User
  extend Dry::Initializer

  param  :name
  option :name # => raises #<SyntaxError ...>
end
```

### Default Values

By default both params and options are mandatory. Use `:default` key to make them optional:

```ruby
class User
  extend Dry::Initializer

  param  :name,  default: 'Unknown user'
  option :email, default: 'unknown@example.com'
end

user = User.new
user.name  # => 'Unknown user'
user.email # => 'unknown@example.com'

user = User.new 'Vladimir', email: 'vladimir@example.com'
user.name  # => 'Vladimir'
user.email # => 'vladimir@example.com'
```

Set `nil` as a default value explicitly:

```ruby
class User
  extend Dry::Initializer

  param :name
  artument :email, default: nil
end

user = User.new 'Andrew'
user.email # => nil

user = User.new
# => #<ArgumentError ...>
```

You can use lambdas|procs as well:

```ruby
class User
  extend Dry::Initializer

  param :name, default: -> { 'Unknown user' }
end

user = User.new
user.name # => 'Unknown user'
```

If you need to **assign** lambda as a default value, wrap it to another one:

```ruby
class User
  extend Dry::Initializer

  param :name_proc, default: -> { -> { 'Unknown user' } }
end

user = User.new
user.name_proc.call # => 'Unknown user'
```

### Order of Declarations

You cannot define required parameter after optional ones. The following example raises `SyntaxError` exception:

```ruby
class User
  extend Dry::Initializer

  param :name, default: 'Unknown name'
  param :email # => #<SyntaxError ...>
end
```

### Type Constraints

To set type constraint use `:type` key:

```ruby
class User
  extend Dry::Initializer

  param :name, type: String
end

user = User.new 'Andrew'
user.name # => 'Andrew'

user = User.new :andrew
# => #<TypeError ...>
```

You can use plain Ruby classes and modules as type constraint (see above), or use [dry-types][dry-types]:

```ruby
class User
  extend Dry::Initializer

  param :name, type: Dry::Types::Coercion::String
end
```

Or you can define custom constraint as a proc:

```ruby
class User
  extend Dry::Initializer

  param :name, type: proc { |v| raise TypeError if String === v }
end

user = User.new name: 'Andrew'
# => #<TypeError ...>
```

[dry-types]: https://github.com/dryrb/dry-types

### Reader and Writer

By default `attr_reader` is defined for every param and option.

To skip the reader, use `reader: false`:

```ruby
class User
  extend Dry::Initializer

  param :name
  param :email, reader: false
end

user = User.new 'Luke', 'luke@example.com'
user.name  # => 'Luke'

user.email                         # => #<NoMethodError ...>
user.instance_variable_get :@email # => 'luke@example.com'
```

By default `attr_writer` is NOT defined (we prefer immutable instances).

To define it, use `writer: true` explicitly:

```ruby
class User
  extend Dry::Initializer

  param :name
  param :email, writer: true
end

user = User.new 'Mark', 'mark@example.com'
user.email # => 'mark@example.com'
user.email = nil
user.email # => nil
```

### Subclassing

Subclassing preserves definitions being made inside a superclass:

```ruby
class User
  extend Dry::Initializer

  param :name
end

class Employee < User
  param :position
end

employee = Employee.new('John', 'supercargo')
employee.name     # => 'John'
employee.position # => 'supercargo'
```

## Benchmarks

[At first][benchmark-options] we compared initializers for case of no-opts with those with default values and time constraints (for every single argument):

```
Benchmark for various options
Warming up --------------------------------------
             no opts     75.483k i/100ms
       with defaults     59.591k i/100ms
          with types     54.935k i/100ms
with defaults and types  49.790k i/100ms
Calculating -------------------------------------
             no opts       1.052M (± 3.8%) i/s -     15.776M
       with defaults     817.603k (± 3.1%) i/s -     12.276M
          with types     737.577k (± 2.6%) i/s -     11.097M
with defaults and types  663.283k (± 2.9%) i/s -      9.958M

Comparison:
             no opts:    1052049.5 i/s
       with defaults:     817603.4 i/s - 1.29x slower
          with types:     737576.7 i/s - 1.43x slower
with defaults and types:  663282.9 i/s - 1.59x slower
```

We also compared initializers provided by gems from the [post 'Con-Struct Attibutes' by Jan Lelis][con-struct]:

* [active_attr][active_attr]
* [anima][anima]
* [concord][concord]
* [fast_attr][fast_attr]
* [kwattr][kwattr]
* [value_struct][value_struct]
* [values][values]
* [virtus][virtus]

Because the gems has their restrictions, in benchmarks we tested only comparable examples.
A corresponding code in plain Ruby was taken for comparison.

### Without Options

Results for [the examples][benchmark_without_options]

```
Benchmark for instantiation of params without default values and types

Warming up --------------------------------------
          plain Ruby   140.858k i/100ms
         Core Struct   144.816k i/100ms
              values    45.977k i/100ms
        value_struct   144.527k i/100ms
     dry-initializer   136.486k i/100ms
             concord    79.026k i/100ms
         attr_extras    41.678k i/100ms
Calculating -------------------------------------
          plain Ruby      4.162M (± 3.1%) i/s -     62.400M
         Core Struct      4.520M (± 0.9%) i/s -     67.919M
              values    637.397k (± 0.7%) i/s -      9.563M
        value_struct      4.479M (± 1.4%) i/s -     67.205M
     dry-initializer      3.981M (± 1.7%) i/s -     59.781M
             concord      1.373M (± 1.4%) i/s -     20.626M
         attr_extras    556.343k (± 0.6%) i/s -      8.377M

Comparison:
         Core Struct:  4520294.5 i/s
        value_struct:  4479181.2 i/s - same-ish: difference falls within error
          plain Ruby:  4161762.2 i/s - 1.09x slower
     dry-initializer:  3981426.3 i/s - 1.14x slower
             concord:  1372696.9 i/s - 3.29x slower
              values:   637396.9 i/s - 7.09x slower
         attr_extras:   556342.9 i/s - 8.13x slower
```

```
Benchmark for instantiation of named arguments (options) without options

Warming up --------------------------------------
          plain Ruby    70.050k i/100ms
     dry-initializer    68.250k i/100ms
               anima    31.734k i/100ms
              kwattr    33.153k i/100ms
Calculating -------------------------------------
          plain Ruby      1.010M (± 0.6%) i/s -     15.201M
     dry-initializer      1.020M (± 3.2%) i/s -     15.288M
               anima    377.388k (± 2.7%) i/s -      5.680M
              kwattr    394.574k (± 1.3%) i/s -      5.934M

Comparison:
     dry-initializer:  1020257.3 i/s
          plain Ruby:  1009705.8 i/s - same-ish: difference falls within error
              kwattr:   394574.0 i/s - 2.59x slower
               anima:   377387.8 i/s - 2.70x slower
```

### With Default Values

Results for [the examples][benchmark_with_defaults]

```
Benchmark for instantiation of named arguments (options) with default values

Warming up --------------------------------------
          plain Ruby   129.643k i/100ms
     dry-initializer    87.231k i/100ms
              kwattr    43.433k i/100ms
         active_attr    25.247k i/100ms
Calculating -------------------------------------
          plain Ruby      3.356M (± 3.3%) i/s -     50.301M
     dry-initializer      1.480M (± 1.2%) i/s -     22.244M
              kwattr    558.216k (± 1.8%) i/s -      8.383M
         active_attr    292.117k (± 1.0%) i/s -      4.393M

Comparison:
          plain Ruby:  3355597.4 i/s
     dry-initializer:  1479976.6 i/s - 2.27x slower
              kwattr:   558215.9 i/s - 6.01x slower
         active_attr:   292116.7 i/s - 11.49x slower
```

### With Type Constraints

Results for [the examples][benchmark_with_types]

```
Benchmark for instantiation of named arguments (options) with type constraints

Warming up --------------------------------------
          plain Ruby    64.740k i/100ms
     dry-initializer    50.799k i/100ms
              virtus    12.873k i/100ms
     fast_attributes    42.622k i/100ms
Calculating -------------------------------------
          plain Ruby    951.575k (± 1.2%) i/s -     14.308M
     dry-initializer    701.677k (± 0.7%) i/s -     10.566M
              virtus    143.113k (± 1.7%) i/s -      2.150M
     fast_attributes    562.646k (± 0.6%) i/s -      8.439M

Comparison:
          plain Ruby:   951574.7 i/s
     dry-initializer:   701676.7 i/s - 1.36x slower
     fast_attributes:   562646.4 i/s - 1.69x slower
              virtus:   143113.3 i/s - 6.65x slower
```

### With Default Values and Type Constraints

Results for [the examples][benchmark_with_types_and_defaults]

```
Benchmark for instantiation of named arguments (options)
with type constraints and default values

Warming up --------------------------------------
          plain Ruby   119.975k i/100ms
     dry-initializer    70.151k i/100ms
              virtus    15.482k i/100ms
Calculating -------------------------------------
          plain Ruby      2.914M (± 0.9%) i/s -     43.791M
     dry-initializer      1.063M (± 0.8%) i/s -     15.994M
              virtus    180.346k (± 1.7%) i/s -      2.709M

Comparison:
          plain Ruby:  2913803.1 i/s
     dry-initializer:  1063474.9 i/s - 2.74x slower
              virtus:   180346.0 i/s - 16.16x slower
```

To recap, `dry-initializer` is a fastest DSL for rubies 2.2+ except for cases when core `Struct` is sufficient.

[benchmark-options]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/options.rb
[benchmark_without_options]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/without_options.rb
[benchmark_with_defaults]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_defaults.rb
[benchmark_with_types]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_types.rb
[benchmark_with_types_and_defaults]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_types_and_defaults.rb
[benchmark_params]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/params.rb
[con-struct]: http://idiosyncratic-ruby.com/18-con-struct-attributes.html
[active_attr]: https://github.com/cgriego/active_attr
[anima]: https://github.com/mbj/anima
[attr_extras]: https://github.com/barsoom/attr_extras
[concord]: https://github.com/mbj/concord
[fast_attr]: https://github.com/applift/fast_attributes
[kwattr]: https://github.com/etiennebarrie/kwattr
[value_struct]: https://github.com/janlelis/value_struct
[values]: https://github.com/tcrayford/values
[virtus]: https://github.com/solnic/virtus

## Compatibility

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

## Contributing

* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE)
* [Fork the project](https://github.com/nepalez/query_builder)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

