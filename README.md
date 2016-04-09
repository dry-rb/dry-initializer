# dry-initializer [![Join the chat at https://gitter.im/dry-rb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dry-rb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-initializer.svg)][gem]
[![Build Status](https://travis-ci.org/dry-rb/dry-initializer.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dry-rb/dry-initializer.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dry-rb/dry-initializer/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dry-rb/dry-initializer/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dry-rb/dry-initializer.svg?branch=master)][inchpages]

[gem]: https://rubygems.org/gems/dry-initializer
[travis]: https://travis-ci.org/dry-rb/dry-initializer
[gemnasium]: https://gemnasium.com/dry-rb/dry-initializer
[codeclimate]: https://codeclimate.com/github/dry-rb/dry-initializer
[coveralls]: https://coveralls.io/r/dry-rb/dry-initializer
[inchpages]: http://inch-ci.org/github/dry-rb/dry-initializer

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

  # Params of the initializer along with corresponding readers
  param  :name, type: String
  param  :role, default: proc { 'customer' }
  # Options of the initializer along with corresponding readers
  option :admin, default: proc { false }
end

# Defines the initializer with params and options
user = User.new 'Vladimir', 'admin', admin: true

# Defines readers for single attributes
user.name  # => 'Vladimir'
user.role  # => 'admin'
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

Use `option` to define named (hash) argument:

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

  param  :name,  default: proc { 'Unknown user' }
  option :email, default: proc { 'unknown@example.com' }
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
  option :email, default: proc { nil }
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

Proc will be executed in a scope of new instance. You can refer to other arguments:

```ruby
class User
  extend Dry::Initializer

  param :name
  param :email, default: proc { "#{name.downcase}@example.com" }
end

user = User.new 'Andrew'
user.email # => 'andrew@example.com'
```

**Warning**: when using lambdas instead of procs, don't forget an argument, required by [instance_eval][instance_eval] (you can skip in in a proc).

```ruby
class User
  extend Dry::Initializer

  param :name, default: -> (obj) { 'Dude' }
end
```

[instance_eval]: http://ruby-doc.org/core-2.2.0/BasicObject.html#method-i-instance_eval

### Order of Declarations

You cannot define required parameter after optional ones. The following example raises `SyntaxError` exception:

```ruby
class User
  extend Dry::Initializer

  param :name, default: proc { 'Unknown name' }
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

### Reader

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

No writers are defined. Define them using pure ruby `attr_writer` when necessary.

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

## Benchmarks

### Various usages of Dry::Initializer

[At first][benchmark-options] we compared initializers for case of no-opts with those with default values and time constraints (for every single argument):

```
             no opts:   1186020.0 i/s
        with 2 types:    744825.4 i/s - 1.59x slower
     with 2 defaults:    644170.0 i/s - 1.84x slower
with defaults and types: 534200.0 i/s - 2.22x slower
```

Defaults are slow. The more defaults you add the slower the instantiation. Let's [add details][benchmark_several_defaults]:

```
        without defaults:   3412165.6 i/s
with 0 of 1 default used:   1816946.6 i/s - 1.88x slower
with 0 of 2 defaults used:  1620908.5 i/s - 2.11x slower
with 0 of 3 defaults used:  1493410.6 i/s - 2.28x slower
with 1 of 1 default used:    797438.8 i/s - 4.28x slower
with 1 of 2 defaults used:   754533.4 i/s - 4.52x slower
with 1 of 3 defaults used:   716828.9 i/s - 4.76x slower
with 2 of 2 defaults used:   622569.8 i/s - 5.48x slower
with 2 of 3 defaults used:   604062.1 i/s - 5.65x slower
with 3 of 3 defaults used:   533233.4 i/s - 6.40x slower
```

A single declaration of default values costs about 90% additional time. Its usage costs full 300%, and every next default adds 80% more.

Avoid defaults when possible!

### Comparison to Other Gems

We also compared initializers provided by gems from the [post 'Con-Struct Attibutes' by Jan Lelis][con-struct]:

* [active_attr][active_attr]
* [anima][anima]
* [attr_extras][attr_extras]
* [concord][concord]
* [fast_attr][fast_attr]
* [kwattr][kwattr]
* [value_struct][value_struct]
* [values][values]
* [virtus][virtus]

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

Because the gems has their restrictions, in benchmarks we tested only comparable examples.
A corresponding code in plain Ruby was taken for comparison.

### Without Options

Results for [the examples][benchmark_without_options]

Benchmark for instantiation of plain arguments (params):

```
         Core Struct:  4520294.5 i/s
        value_struct:  4479181.2 i/s - same-ish: difference falls within error
          plain Ruby:  4161762.2 i/s - 1.09x slower
     dry-initializer:  3981426.3 i/s - 1.14x slower
             concord:  1372696.9 i/s - 3.29x slower
              values:   637396.9 i/s - 7.09x slower
         attr_extras:   556342.9 i/s - 8.13x slower
```

Benchmark for instantiation of named arguments (options)

```
     dry-initializer:  1020257.3 i/s
          plain Ruby:  1009705.8 i/s - same-ish: difference falls within error
              kwattr:   394574.0 i/s - 2.59x slower
               anima:   377387.8 i/s - 2.70x slower
```

### With Default Values

Results for [the examples][benchmark_with_defaults]

```
          plain Ruby:  3534979.5 i/s
     dry-initializer:   657308.4 i/s - 5.38x slower
              kwattr:   581691.0 i/s - 6.08x slower
         active_attr:   309211.0 i/s - 11.43x slower
```

### With Type Constraints

Results for [the examples][benchmark_with_types]

```
          plain Ruby:   951574.7 i/s
     dry-initializer:   701676.7 i/s - 1.36x slower
     fast_attributes:   562646.4 i/s - 1.69x slower
              virtus:   143113.3 i/s - 6.65x slower
```

### With Default Values and Type Constraints

Results for [the examples][benchmark_with_types_and_defaults]

```
          plain Ruby:  2887933.4 i/s
     dry-initializer:   532508.0 i/s - 5.42x slower
              virtus:   183347.1 i/s - 15.75x slower
```

To recap, `dry-initializer` is a fastest DSL for rubies 2.2+ except for cases when core `Struct` is sufficient.

[benchmark-options]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/options.rb
[benchmark_several_defaults]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/several_defaults.rb
[benchmark_without_options]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/without_options.rb
[benchmark_with_defaults]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_defaults.rb
[benchmark_with_types]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_types.rb
[benchmark_with_types_and_defaults]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/with_types_and_defaults.rb
[benchmark_params]: https://github.com/dryrb/dry-initializer/blob/master/benchmarks/params.rb

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

