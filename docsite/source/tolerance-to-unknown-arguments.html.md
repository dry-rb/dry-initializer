---
title: Tolerance to Unknown Arguments
layout: gem-single
name: dry-initializer
---

By default the initializer is tolerant for both params (positional arguments) and options.
All unknown arguments of the initializer are ignored silently.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer
end

user = User.new 'Joe', role: 'admin'
user.respond_to? :role # => false

User.dry_initializer.attributes(user)
# => {}
```

Unknown arguments are stored in a pair of properties

```ruby
user.__dry_initializer_unknown_params__  # => ['Joe']
user.__dry_initializer_unknown_options__ # => {role: 'admin'}
```

The names of the rest params and the rest options are configurable. 

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  rest_params :args
  rest_options :kwargs
end

user = User.new 'Joe', role: 'admin'
user.args   # => ['Joe']
user.kwargs # => {role: 'admin'}
user.respond_to? :__dry_initializer_unknown_params__  # => false
user.respond_to? :__dry_initializer_unknown_options__ # => false
```

Setting rest params or rest options to false results in strict argument checking.
Unknown arguments will result in ArgumentErrors.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  rest_params false
  rest_options false
end

user = User.new 'Joe'         # => raises ArgumentError
user = User.new role: 'admin' # => raises ArgumentError

```