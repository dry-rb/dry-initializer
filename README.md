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

  # Define params of the initializer along with corresponding readers
  param  :name, type: String
  param  :type, default: -> { 'customer' }
  # Define options of the initializer along with corresponding readers
  option :admin, default: -> { false }
  # Define hash to access attributes
  attr_hash :types, :type, :admin
end

# Defines the initializer with params and options
user = User.new 'Vladimir', 'admin', admin: true

# Defines readers for single attributes
user.name  # => 'Vladimir'
user.type  # => 'admin'
user.admin # => true

# Defines hash for mass access to variables
user.types # => { type: 'admin', admin: true }
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

  def types
    { type: @type, admin: @admin }
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

  param  :name,  default: -> { 'Unknown user' }
  option :email, default: -> { 'unknown@example.com' }
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

  param  :name
  option :email, default: -> { nil }
end

user = User.new 'Andrew'
user.email # => nil

user = User.new
# => #<ArgumentError ...>
```

You **must** wrap default values into procs.

If you need to **assign** proc as a default value, wrap it to another one:

```ruby
class User
  extend Dry::Initializer

  param :name_proc, default: proc { proc { 'Unknown user' } }
end

user = User.new
user.name_proc.call # => 'Unknown user'
```

### Order of Declarations

You cannot define required parameter after optional ones. The following example raises `SyntaxError` exception:

```ruby
class User
  extend Dry::Initializer

  param :name, default: -> { 'Unknown name' }
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

Subclassing preserves all definitions being made inside a superclass:

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

### Attributes

Use `attr_hash` to define hash reader for instance variables. Keys `:reader` and `:writer` works as usual:

```ruby
class User
  extend Dry::Initializer

  param  :name
  option :email, default: -> { nil }
  attr_hash :name_and_email, :name, :email, writer: true
end

user = User.new 'Andrew', email: 'andrew@example.com'

user.name_and_email # => { name: 'Andrew', email: 'andrew@example.com' }
user.name_and_email = { name: 'Vladimir', email: 'vladimir@example.com' }

user.name  # => 'Vladimir'
user.email # => 'vladimir@example.com'
```

## Benchmarks

[At first][benchmark-options] we compared initializers for case of no-opts with those with default values and time constraints (for every single argument):

```
Benchmark for various options

Calculating -------------------------------------
             no opts      1.097M (± 2.6%) i/s - 16.454M
       with defaults    789.390k (± 7.3%) i/s - 11.788M
          with types    696.021k (± 4.3%) i/s - 10.459M
with defaults and types 669.247k (± 2.2%) i/s - 10.063M

Comparison:
             no opts:   1097136.2 i/s
       with defaults:    789389.9 i/s - 1.39x slower
          with types:    696020.6 i/s - 1.58x slower
with defaults and types: 669247.4 i/s - 1.64x slower
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
Benchmark for instantiation of params

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
Benchmark for instantiation of named arguments (options)

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

Calculating -------------------------------------
          plain Ruby      3.480M (± 2.1%) i/s -     52.172M
     dry-initializer      1.307M (± 1.0%) i/s -     19.662M
              kwattr    589.197k (± 1.2%) i/s -      8.870M
         active_attr    308.514k (± 1.5%) i/s -      4.649M

Comparison:
          plain Ruby:  3480357.8 i/s
     dry-initializer:  1306677.7 i/s - 2.66x slower
              kwattr:   589196.8 i/s - 5.91x slower
         active_attr:   308513.7 i/s - 11.28x slower
```

### With Type Constraints

Results for [the examples][benchmark_with_types]

```
Benchmark for instantiation of named arguments (options) with type constraints

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

Calculating -------------------------------------
          plain Ruby      2.943M (± 1.7%) i/s -     44.216M
     dry-initializer    972.919k (± 0.8%) i/s -     14.630M
              virtus    180.727k (± 1.2%) i/s -      2.717M

Comparison:
          plain Ruby:  2942988.7 i/s
     dry-initializer:   972919.1 i/s - 3.02x slower
              virtus:   180727.1 i/s - 16.28x slower
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

