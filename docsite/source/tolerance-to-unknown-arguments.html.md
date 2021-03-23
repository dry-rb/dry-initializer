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
