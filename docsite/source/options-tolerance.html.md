---
title: Tolerance to Unknown Options
layout: gem-single
name: dry-initializer
---

By default the initializer is strict for params (positional arguments), expecting them to be defined explicitly.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer
end

user = User.new 'Joe' # raises ArgumentError
```

At the same time it is tolerant to unknown options. All unknown options are accepted, but ignored:

```ruby
# It accepts undefined options...
user = User.new name: 'Joe'

# ...but ignores them
user.respond_to? :name # => false
```
