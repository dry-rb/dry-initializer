---
title: Inheritance
layout: gem-single
name: dry-initializer
---

Subclassing preserves all definitions being made inside a superclass.

```ruby
require 'dry-initializer'

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

employee = Employee.new # => fails because type
```

You can override params and options.
Such overriding leaves initial order of params (positional arguments) unchanged:

```ruby
class Employee < User
  param :position, optional: true
  param :name,     default:  proc { 'Unknown' }
end

user = User.new         # => Boom! because User#name is required
employee = Employee.new # passes because who cares on employee's name

employee.name
# => 'Unknown' because it is the name that positioned first like in User
```
