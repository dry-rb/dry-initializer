---
title: Attributes
layout: gem-single
name: dry-initializer
---

Sometimes you need to access all attributes assigned via params and options of the object constructor.

We support 2 methods: `attributes` and `public_attributes` for this goal. Both methods are wrapped into container accessible via `.dry_initializer` container:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name
  option :email,   optional: true
  option :telefon, optional: true, as: :phone
end

user = User.new "Andy", telefon: "71002003040"

User.dry_initializer.attributes(user)
# => { name: "Andy", phone: "71002003040" }
```

What the method does is extracts *variables assigned* to the object (and skips unassigned ones like the `email` above). It doesn't matter whether you send it via `params` or `option`; we look at the result of the instantiation, not at the interface.

Method `public_attributes` works different. Let's look at the following example to see the difference:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name
  option :telefon,  optional: true, as: :phone
  option :email,    optional: true
  option :token,    optional: true, reader: :private
  option :password, optional: true, reader: false
end

user = User.new "Andy", telefon: "71002003040", token: "foo", password: "bar"

User.dry_initializer.attributes(user)
# => { name: "Andy", phone: "71002003040", token: "foo", password: "bar" }

User.dry_initializer.public_attributes(user)
# => { name: "Andy", phone: "71002003040", email: nil }
```

Notice that `public_attribute` reads *public reader methods*, not variables. That's why it skips both the private `token`, and the `password` whose reader hasn't been defined.

Another difference concerns unassigned values. Because the reader `user.email` returns `nil` (its `@email` variable contains `Dry::Initializer::UNDEFINED` constant), the `public_attributes` adds this value to the hash using the method.

The third thing to mention is that you can override the reader, and it is the overriden method which will be used by `public_attributes`:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name
  option :password, optional: true

  def password
    super.hash.to_s
  end
end

user = User.new "Joe", password: "foo"

User.dry_initializer.attributes(user)
# => { user: "Joe", password: "foo" }

User.dry_initializer.public_attributes(user)
# => { user: "Joe", password: "-1844874613000160009" }
```

This feature works for the "extend Dry::Initializer" syntax. But what about "include Dry::Initializer.define ..."? Now we don't pollute class namespace with new methods, that's why `.dry_initializer` is absent.

To access config you can use a hack. Under the hood we define private instance method `#__dry_initializer_config__` which refers to the same container. So you can write:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer
  param :name
end

user = User.new "Joe"

user.send(:__dry_initializer_config__).attributes(user)
# => { user: "Joe" }

user.send(:__dry_initializer_config__).public_attributes(user)
# => { user: "Joe" }
```

This is a hack because the `__dry_initializer_config__` is not a part of the gem's public interface; there's a possibility it can be changed or removed in the later releases.

We'll try to be careful with it, and mark it as deprecated method in case of such a removal.
