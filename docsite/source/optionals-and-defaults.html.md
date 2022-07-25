---
title: Optional Attributes and Default Values
layout: gem-single
name: dry-initializer
---

By default both params and options are mandatory. Use `:default` key to make them optional:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name,  default: proc { 'Unknown user' }
  option :email, default: proc { 'unknown@example.com' }
  option :phone, optional: true
end

user = User.new
user.name  # => 'Unknown user'
user.email # => 'unknown@example.com'
user.phone # => Dry::Initializer::UNDEFINED

user = User.new 'Vladimir', email: 'vladimir@example.com', phone: '71234567788'
user.name  # => 'Vladimir'
user.email # => 'vladimir@example.com'
user.phone # => '71234567788'
```

You cannot define required **parameter** after optional one. The following example raises `SyntaxError` exception:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name, default: proc { 'Unknown name' }
  param :email # => #<SyntaxError ...>
end
```

You should assign `nil` value explicitly. Otherwise an instance variable it will be left undefined. In both cases attribute reader method will return `nil`.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name
  option :email, optional: true
end

user = User.new 'Andrew'
user.email # => nil
user.instance_variable_get :@email
# => Dry::Initializer::UNDEFINED

user = User.new 'Andrew', email: nil
user.email # => nil
user.instance_variable_get :@email
# => nil
```

You can also set `nil` as a default value:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name
  option :email, default: proc { nil }
end

user = User.new 'Andrew'
user.email # => nil
user.instance_variable_get :@email
# => nil
```

You **must** wrap default values into procs.

If you need to **assign** proc as a default value, wrap it to another one:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name_proc, default: proc { proc { 'Unknown user' } }
end

user = User.new
user.name_proc.call # => 'Unknown user'
```

Proc will be executed in a scope of new instance. You can refer to other arguments:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name
  param :email, default: proc { "#{name.downcase}@example.com" }
end

user = User.new 'Andrew'
user.email # => 'andrew@example.com'
```
