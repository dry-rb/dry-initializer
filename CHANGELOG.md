## v1.4.1 2017-04-05

### Fixed
- Warning about redefined `#initialize` in case the method reloaded in a klass
  that extends the module (nepalez, sergey-chechaev)

### Internals
- Rename `Dry::Initializer::DSL` -> `Dry::Initializer::ClassDSL` (nepalez)
- Add `Dry::Initializer::InstanceDSL` (nepalez)

[Compare v1.4.0...v1.4.1](https://github.com/dry-rb/dry-initializer/compare/v1.4.0...v1.4.1)

## v1.4.0 2017-03-08

### Changed (backward-incompatible)
- The `@__options__` hash now collects all assigned attributes,
  collected via `#option` (as before), and `#param` (nepalez)

[Compare v1.3.0...v1.4.0](https://github.com/dry-rb/dry-initializer/compare/v1.3.0...v1.4.0)

## v1.3.0 2017-03-05

### Added
- No-undefined configuration of the initializer (nepalez, flash-gordon)
  
  You can either extend or include module `Dry::Initializer` with additional option
  `[undefined: false]`. This time `nil` will be assigned instead of
  `Dry::Initializer::UNDEFINED`. Readers becomes faster because there is no need
  to chech whether a variable was defined or not. At the same time the initializer
  doesn't distinct cases when a variable was set to `nil` explicitly, and when it wasn's set at all:

    class Foo # old behavior
      extend Dry::Initializer
      param :qux, optional: true
    end

    class Bar # new behavior
      extend Dry::Initializer[undefined: false]
      param :qux, optional: true
    end

    Foo.new.instance_variable_get(:@qux) # => Dry::Initializer::UNDEFINED
    Bar.new.instance_variable_get(:@qux) # => nil

### Internals
- Fixed method definitions for performance at the load time (nepalez, flash-gordon)

[Compare v1.2.0...v1.3.0](https://github.com/dry-rb/dry-initializer/compare/v1.2.0...v1.3.0)

## v1.2.0 2017-03-05

### Fixed
- The `@__options__` variable collects renamed options after default values and coercions were applied (nepalez)

[Compare v1.1.3...v1.2.0](https://github.com/dry-rb/dry-initializer/compare/v1.1.3...v1.2.0)

## v1.1.3 2017-03-01

### Added
- Support for lambdas as default values (nepalez, gzigzigzeo)

[Compare v1.1.2...v1.1.3](https://github.com/dry-rb/dry-initializer/compare/v1.1.2...v1.1.3)

## v1.1.2 2017-02-06

### Internals
- Remove previously defined methods before redefining them (flash-gordon)

[Compare v1.1.1...v1.1.2](https://github.com/dry-rb/dry-initializer/compare/v1.1.1...v1.1.2)

## v1.1.1 2017-02-04

### Bugs Fixed
- `@__options__` collects defined options only (nepalez)

[Compare v1.1.0...v1.1.1](https://github.com/dry-rb/dry-initializer/compare/v1.1.0...v1.1.1)

## v1.1.0 2017-01-28

### Added:
- enhancement via `Dry::Initializer::Attribute.dispatchers` registry (nepalez)

    # Register dispatcher for `:string` option
    Dry::Initializer::Attribute.dispatchers << ->(string: nil, **op) do
      string ? op.merge(type: proc(&:to_s)) : op
    end

    # Now you can use the `:string` key for `param` and `option`
    class User
      extend Dry::Initializer
      param :name, string: true
    end

    User.new(:Andy).name # => "Andy"

### Internals:
- optimize assignments for performance (nepalez)

[Compare v1.0.0...v1.1.0](https://github.com/dry-rb/dry-initializer/compare/v1.0.0...v1.1.0)

## v1.0.0 2017-01-22

In this version the code has been rewritten for simplicity

### BREAKING CHANGES
- when `param` or `option` was not defined, the corresponding **variable** is set to `Dry::Initializer::UNDEFINED`, but the **reader** (when defined) will return `nil` (nepalez)

### Added:
- support for reloading `param` and `option` definitions (nepalez)

    class User
      extend Dry::Initializer
      param :name
      param :phone, optional: true
    end

    User.new # => Boom!

    class Admin < User
      param :name, default: proc { 'Merlin' }
    end

    # order of the param not changed
    Admin.new.name # => "Merlin"

- support for assignment of attributes via several options (nepalez)

    class User
      extend Dry::Initializer
      option :phone
      option :number, as: :phone
    end

    # Both ways provide the same result
    User.new(phone: '1234567890').phone   # => '1234567890'
    User.new(number: '1234567890').phone # => '1234567890'

### Internals
- `Dry::Initializer` and `Dry::Initializer::Mixin` became aliases (nepalez)

[Compare v0.11.0...v1.0.0](https://github.com/dry-rb/dry-initializer/compare/v0.11.0...v1.0.0)

## v0.11.0 2017-01-02

### Added

* Support of reloading `#initializer` with `super` (nepalez)

### Internal

* Refactor the way [#initializer] method is (re)defined (nepalez)
  
  When you extend class with `Dry::Initializer::Mixin`, the initializer is
  defined not "inside" the class per se, but inside the included module. The
  reference to that module is stored as class-level `__initializer_mixin__`.

  Mixin method [#initialize] calls another private method [#__initialize__].
  It is this method to be reloaded every time you envoke a helper
  `option` or `product`.

  When new subclass is inherited, new mixin is added to chain of accessors,
  but this time it does reload `__initialize__` only, not the `initialize`.
  That is how you can safely reload initializer using `super`, but at the same
  time use the whole power of dry-initializer DSL both in parent class and its
  subclasses.

  The whole stack of accessors looks like the following:
  - Parent class mixin: `initialize` --> `__initialize__`
                             ^
  - Parent class:       `initialize`
  - Subclass mixin:          ^           `__initialize__`
  - Subclass:           `initialize`

  See specification `spec/custom_initializer_spec.rb` to see how this works.

[Compare v0.10.2...v0.11.0](https://github.com/dry-rb/dry-initializer/compare/v0.10.2...v0.11.0)

## v0.10.2 2016-12-31

### Added

* Support of Ruby 2.4 (flas-gordon)

### Internal

* Code clearance for ROM integration (flash-gordon)

[Compare v0.10.1...v0.10.2](https://github.com/dry-rb/dry-initializer/compare/v0.10.1...v0.10.2)

## v0.10.1 2016-12-27

### Fixed

* Wrong arity when there were no options and the last param had a default (nolith)

[Compare v0.10.0...v0.10.1](https://github.com/dry-rb/dry-initializer/compare/v0.10.0...v0.10.1)

## v0.10.0 2016-11-20

### Deleted (BREAKING CHANGE!)

* Deprecated method DSL#using (nepalez)

[Compare v0.9.3...v0.10.0](https://github.com/dry-rb/dry-initializer/compare/v0.9.3...v0.10.0)

## v0.9.3 2016-11-20

### Deprecated

* After discussion in [PR #17](https://github.com/dry-rb/dry-initializer/pull/17)
  (many thanks to @sahal2080 and @hrom512 for starting that issue and PR),
  the method `using` is deprecated and will be removed from v0.10.0 (nepalez)

### Fixed

* Support of weird option names (nepalez)

  ```ruby
  option :"First name", as: :first_name
  ```

[Compare v0.9.2...v0.9.3](https://github.com/dry-rb/dry-initializer/compare/v0.9.2...v0.9.3)

## v0.9.2 2016-11-10

### Fixed

* Validation of attributes (params and options) (nepalez)

[Compare v0.9.1...v0.9.2](https://github.com/dry-rb/dry-initializer/compare/v0.9.1...v0.9.2)

## v0.9.1 2016-11-06

### Added

* Support for renaming an option during initialization (nepalez)

  option :name, as: :username # to take :name option and create :username attribute

[Compare v0.9.0...v0.9.1](https://github.com/dry-rb/dry-initializer/compare/v0.9.0...v0.9.1)

## v0.9.0 2016-11-06

### Added

* The method `#initialize` is defined when a class extended the module (nepalez)

  In previous versions the method was defined only by `param` and `option` calls.

### Breaking Changes

* The initializer accepts any option (but skips unknown) from the very beginning (nepalez)

### Deleted

* Deprecated methods `tolerant_to_unknown_options` and `intolerant_to_unknown_options` (nepalez)

### Internal

* Refactor scope (`using`) to support methods renaming and aliasing (nepalez)

[Compare v0.8.1...v0.9.0](https://github.com/dry-rb/dry-initializer/compare/v0.8.1...v0.9.0)

## v0.8.1 2016-11-05

### Added

* Support for `dry-struct`ish syntax for constraints (type as a second parameter) (nepalez)

    option :name, Dry::Types['strict.string']

[Compare v0.8.0...v0.8.1](https://github.com/dry-rb/dry-initializer/compare/v0.8.0...v0.8.1)

## v0.8.0 2016-11-05

In this version we switched from key arguments to ** to support special keys:

    option :end
    option :begin

In previous versions this was translated to

    def initialize(end:, begin:)
      @end   = end   # BOOM! SyntaxError!
      @begin = begin # Potential BOOM (unreached)
    end

Now the assignment is imlemented like this:

    def initialize(**__options__)
      @end   = __options__.fetch(:end)
      @begin = __options__.fetch(:begin)
    end

As a side effect of the change the initializer becomes tolerant
to any unknown option if, and only if some `option` was set explicitly.

Methods `tolerant_to_unknown_options` and `intolerant_to_unknown_options`
are deprecated and will be removed in the next version of the gem.

### Added

* support for special options like `option :end`, `option :begin` etc. (nepalez)

### Internals

* switched from key arguments to serialized hash argument in the initializer (nepalez)

### Breaking Changes

* the initializer becomes tolerant to unknown options when any `option` was set,
  ignoring `intolerant_to_unknown_options` helper.

* the initializer becomes intolerant to options when no `option` was set,
  ignoring `tolerant_to_unknown_options` helper.

### Deprecated

* `tolerant_to_unknown_options`
* `intolerant_to_unknown_options`

[Compare v0.7.0...v0.8.0](https://github.com/dry-rb/dry-initializer/compare/v0.7.0...v0.8.0)

## v0.7.0 2016-10-11

### Added

* Shared settings with `#using` method (nepalez)

[Compare v0.6.0...v0.7.0](https://github.com/dry-rb/dry-initializer/compare/v0.6.0...v0.7.0)

## v0.6.0 2016-10-09

### Added

* Support for private and protected readers in the `reader:` option (jmgarnier)

[Compare v0.5.0...v0.6.0](https://github.com/dry-rb/dry-initializer/compare/v0.5.0...v0.6.0)

## v0.5.0 2016-08-21

### Added

* Allow `optional` attribute to be left undefined (nepalez)

[Compare v0.4.0...v0.5.0](https://github.com/dry-rb/dry-initializer/compare/v0.4.0...v0.5.0)

## v0.4.0 2016-05-28

### Deleted (backward-incompatible changes)

* Support of modules and case equality as type constraints (nepalez)

[Compare v0.3.3...v0.4.0](https://github.com/dry-rb/dry-initializer/compare/v0.3.3...v0.4.0)

## v0.3.3 2016-05-28

* Add deprecation warnings about modules and case equality as type constraints (nepalez)

[Compare v0.3.2...v0.3.3](https://github.com/dry-rb/dry-initializer/compare/v0.3.2...v0.3.3)

## v0.3.2 2016-05-25

### Bugs Fixed

* Add explicit requirement for ruby 'set' (rickenharp)

[Compare v0.3.1...v0.3.2](https://github.com/dry-rb/dry-initializer/compare/v0.3.1...v0.3.2)

## v0.3.1 2016-05-22

### Added

* Support for tolerance to unknown options (nepalez)

[Compare v0.3.0...v0.3.1](https://github.com/dry-rb/dry-initializer/compare/v0.3.0...v0.3.1)

## v0.3.0 2016-05-19

Breaks interface for adding new plugins. Register new plugin via:

```
def self.extended(klass)
  klass.register_initializer_plugin NewPlugin
end
```

instead of:

```
def self.extended(klass)
  klass.initializer_builder.register NewPlugin
end
```

While the private method ##initializer_builder is still accessible
its method #register doesn't mutate the builder instance.

### Changed (backward-incompatible changes)

* Made Mixin##initializer_builder method private (nepalez)
* Add Mixin#register_initializer_plugin(plugin) method (nepalez)

### Bugs Fixed

* Prevent plugin's registry from polluting superclass (nepalez)

[Compare v0.2.1...v0.3.0](https://github.com/dry-rb/dry-initializer/compare/v0.2.1...v0.3.0)

### Internals

* Make all instances (Builder and Signature) immutable (nepalez)
* Decouple mixin from a builder to prevent pollution (nepalez)
* Ensure default value block can use private variables (jeremyf)

[Compare v0.2.0...v0.2.1](https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1)

## v0.2.1 2016-05-19

### Bugs Fixed

* Fix polluting superclass with declarations from subclass (nepalez)

### Internals

* Make all instances (Builder and Signature) immutable (nepalez)
* Decouple mixin from a builder to prevent pollution (nepalez)
* Ensure default value block can use private variables (jeremyf)

[Compare v0.2.0...v0.2.1](https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1)

## v0.2.0 2016-05-16

The gem internals has been rewritten heavily to make the gem pluggable and fix
bugs in "container style". Type constraints were extracted to a plugin
that should be added explicitly.

Small extensions were added to type constraints to support constraint by any
object, and apply value coercion via `dry-types`.

Default assignments became slower (while plain type constraint are not)!

### Changed (backward-incompatible changes)

* Make dry-types constraint to coerce variables (nepalez)

  ```ruby
  # This will coerce `name: :foo` to `"foo"`
  option :name, type: Dry::Types::Coercible::String
  ```

* Stop supporing proc type constraint (nepalez)

  ```ruby
  option :name, type: ->(v) { String === v } # this does NOT work any more
  ```

  later it will be implemented via coercion plugin (not added by default):

  ```ruby
  require 'dry/initializer/coercion'

  class MyClass
    extend Dry::Initializer::Mixin
    extend Dry::Initializer::Coercion

    option :name, coercer: ->(v) { (String === v) ? v.to_sym : fail }
  end
  ```

### Added

* Support type constraint via every object's case equality (nepalez)

  ```ruby
  option :name, type: /foo/
  option :name, type: (1...14)
  ```

* Support defaults and type constraints for the "container" syntax (nepalez)
* Support adding extensions via plugin system (nepalez)

### Internal

* Private method `##__after_initialize__` is added by the `Mixin` along with `#initialize` (nepalez)

  The previous implementation required defaults and types to be stored in the class method `.initializer_builder`.
  That made "container" syntax to support neither defaults nor types.

  Now the `#initializer` is still defined via `instance_eval(code)` for efficiency. Some operations
  (like default assignments, coercions, dry-type constraints etc.) cannot be implemented in this way.
  They are made inside `##__after_initialize__` callback, that is biult via `default_method(&block)`
  using instance evals.

[Compare v0.1.1...v0.2.0](https://github.com/dry-rb/dry-initializer/compare/v0.1.1...v0.2.0)

## v0.1.1 2016-04-28

### Added

* `include Dry::Initializer.define -> do ... end` syntax (flash-gordon)

[Compare v0.1.0...v0.1.1](https://github.com/dry-rb/dry-initializer/compare/v0.1.0...v0.1.1)

## v0.1.0 2016-04-26

Class DSL splitted to mixin and container versions (thanks to @AMHOL for the idea).
Backward compatibility is broken.

### Changed (backward-incompatible changes)

* Use `extend Dry::Initializer::Mixin` instead of `extend Dry::Initializer` (nepalez)

### Added

* Use `include Dry::Initializer.define(&block)` as an alternative to extending the class (nepalez)

[Compare v0.0.1...v0.1.0](https://github.com/dry-rb/dry-initializer/compare/v0.0.1...v0.1.0)

## v0.0.1 2016-04-09

First public release
