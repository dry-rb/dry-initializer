---
title: Type Constraints
layout: gem-single
name: dry-initializer
---

## Base Syntax

Use `:type` key in a `param` or `option` declarations to add type coercer.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer
  param :name, type: proc(&:to_s)
end

user = User.new :Andrew
user.name # => "Andrew"
```

Any object that responds to `#call` with 1 argument can be used as a type. Common examples are `proc(&:to_s)` for strings, `method(:Array)` (for arrays) or `Array.method(:wrap)` in Rails, `->(v) { !!v }` (for booleans), etc.

## Dry Types as coercers

Another important example is the usage of `dry-types` as type constraints:

```ruby
require 'dry-initializer'
require 'dry-types'

class User
  extend Dry::Initializer
  param :name, type: Dry::Types['strict.string']
end

user = User.new :Andrew # => #<TypeError ...>
```

## Positional Argument

Instead of `:type` option you can send a constraint/coercer as the second argument:

```ruby
require 'dry-initializer'
require 'dry-types'

class User
  extend Dry::Initializer
  param :name,  Dry::Types['coercible.string']
  param :email, proc(&:to_s)
end
```

## Array Types

As mentioned above, the `:type` option takes a callable object... with one important exception.

You can use arrays for values that should be wrapped to array:

```ruby
class User
  extend Dry::Initializer

  option :name,   proc(&:to_s)
  option :emails, [proc(&:to_s)]
end

user = User.new name: "joe", emails: :"joe@example.com"
user.emails # => ["joe@example.com"]

user = User.new name: "jane", emails: [:"jane@example.com", :"jane@example.org"]
user.emails # => ["jane@example.com", "jane@example.org"]
```

You can wrap the coercer into several arrays as well:

```ruby
class User
  extend Dry::Initializer

  option :emails, [[proc(&:to_s)]]
end

user = User.new name: "joe", emails: "joe@example.com"
user.emails # => [["joe@example.com"]]
```

Eventually, you can use an empty array as a coercer. In that case we just wrap the source value(s) into array, not modifying the items:

```ruby
class Article
  extend Dry::Initializer

  option :tags, []
end

article = Article.new(tags: 1)
article.tags # => [1]
```

## Nested Options

Sometimes you need to describe a structure with nested options. In this case you can use a block with `options` inside.

```ruby
class User
  extend Dry::Initializer

  option :name, proc(&:to_s)

  option :emails, [] do
    option :address,     proc(&:to_s)
    option :description, proc(&:to_s)
  end
end

user = User.new name: "joe",
                emails: { address: "joe@example.com", description: "Job email" }

user.emails.class         # => Array
user.emails.first.class   # => User::Emails
user.emails.first.address # => "joe@example.com"

user.emails.map(&:to_h) # => [{ address: "joe@example.com", description: "Job email" }]
```

Notice how we mixed array wrapper with a nested type.

The only syntax restriction here is that you cannot use a positional `param` _inside_ the block.

## Back References

Sometimes you need to refer back to the initialized instance. In this case use a second argument to explicitly give the instance to a coercer:

```ruby
class Location < String
  attr_reader :parameter # refers back to its parameter

  def initialize(name, parameter)
    super(name)
    @parameter = parameter
  end
end

class Parameter
  extend Dry::Initializer
  param :name
  param :location, ->(value, param) { Location.new(value, param) }
end

offset = Parameter.new "offset", "query"
offset.name     # => "offset"
offset.location # => "query"
offset.location.parameter == offset # true
```

[dry-types]: https://github.com/dry-rb/dry-types
[dry-types-docs]: http://dry-rb.org/gems/dry-types/
