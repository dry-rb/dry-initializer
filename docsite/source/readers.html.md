---
title: Readers
layout: gem-single
name: dry-initializer
---

By default public attribute reader is defined for every param and option.

You can define private or protected reader instead:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name,  reader: :private   # the same as adding `private :name`
  param :email, reader: :protected # the same as adding `protected :email`
end
```

To skip any reader, use `reader: false`:

```ruby
require 'dry-initializer'

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

Notice that any other value except for `false`, `:protected` and `:private` provides a public reader.

No writers are defined. Define them using pure ruby `attr_writer` when necessary.
