---
title: Skip Undefined
layout: gem-single
name: dry-initializer
---

The initializer uses special constant `Dry::Initializer::UNDEFINED` to distinguish variables that are set to `nil` from those that are not set at all.

When no value was provided, the constant is assigned to a variable, but hidden in a reader.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer
  option :email, optional: true
end

user = User.new

user.email
# => nil

user.instance_variable_get :@email
# => Dry::Initializer::UNDEFINED
```

This gives you full control of the real state of the attributes. However, all that checks cost about >30% of instantiation time, and make attribute readers 2 times slower.

To avoid the overhead in cases you don't care about the differences between `nil` and undefined, you can use a light version of the module. Add `[undefined: false]` config to either `extend` or `include` line of code:

```ruby
extend Dry::Initializer[undefined: false]
```

```ruby
include Dry::Initializer[undefined: false].define -> do
  # ...
end
```

This time you should expect `nil` every time no value was given to an optional attribute:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer[undefined: false]
  option :email, optional: true
end

user = User.new

user.email
# => nil

user.instance_variable_get :@email
# => nil
```
