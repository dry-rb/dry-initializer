# dry-initializer [![Join the chat at https://gitter.im/dry-rb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dry-rb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-initializer.svg)][gem]
[![Build Status](https://travis-ci.org/dry-rb/dry-initializer.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dry-rb/dry-initializer.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dry-rb/dry-initializer/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dry-rb/dry-initializer/badges/coverage.svg)][coveralls]
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
  extend Dry::Initializer::Mixin

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

### Container Version

Instead of extending a class with the `Dry::Initializer::Mixin`, you can include a container with the initializer:

```ruby
require 'dry-initializer'

class User
  # notice `-> do .. end` syntax
  include Dry::Initializer.define -> do
    param  :name,  type: String
    param  :role,  default: proc { 'customer' }
    option :admin, default: proc { false }
  end
end
```

Now you do not pollute a class with new variables, but isolate them in a special "container" module with the initializer and attribute readers. This method should be preferred when you don't need subclassing.

If you still need the DSL (`param` and `option`) to be inherited, use the direct extension:

```ruby
require 'dry-initializer'

class BaseService
  extend Dry::Initializer::Mixin
  alias_method :dependency, :param
end

class ShowUser < BaseService
  dependency :user

  def call
    puts user&.name
  end
end
```

### Params and Options

Use `param` to define plain argument:

```ruby
class User
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

  param  :name
  option :name # => raises #<SyntaxError ...>
end
```

### Default Values

By default both params and options are mandatory. Use `:default` key to make them optional:

```ruby
class User
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

  param :name_proc, default: proc { proc { 'Unknown user' } }
end

user = User.new
user.name_proc.call # => 'Unknown user'
```

Proc will be executed in a scope of new instance. You can refer to other arguments:

```ruby
class User
  extend Dry::Initializer::Mixin

  param :name
  param :email, default: proc { "#{name.downcase}@example.com" }
end

user = User.new 'Andrew'
user.email # => 'andrew@example.com'
```

**Warning**: when using lambdas instead of procs, don't forget an argument, required by [instance_eval][instance_eval] (you can skip in in a proc).

```ruby
class User
  extend Dry::Initializer::Mixin

  param :name, default: -> (obj) { 'Dude' }
end
```

[instance_eval]: http://ruby-doc.org/core-2.2.0/BasicObject.html#method-i-instance_eval

### Order of Declarations

You cannot define required parameter after optional ones. The following example raises `SyntaxError` exception:

```ruby
class User
  extend Dry::Initializer::Mixin

  param :name, default: proc { 'Unknown name' }
  param :email # => #<SyntaxError ...>
end
```

### Type Constraints

To set type constraint use `:type` key:

```ruby
class User
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

  param :name, type: Dry::Types::Coercion::String
end
```

Or you can define custom constraint as a proc:

```ruby
class User
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

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
  extend Dry::Initializer::Mixin

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

The `dry-initializer` is a [fastest DSL][benchmarks] for rubies 2.2+ except for cases when core `Struct` is sufficient.

[benchmarks]: https://github.com/dry-rb/dry-initializer/wiki

## Compatibility

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

## Contributing

* [Fork the project](https://github.com/dry-rb/dry-initializer)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

