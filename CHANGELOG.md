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

* Made Mixin##initializer_builder method private (@nepalez)
* Add Mixin#register_initializer_plugin(plugin) method (@nepalez)

### Bugs Fixed

* Prevent plugin's registry from polluting superclass (@nepalez)

[Compare v0.2.1...v0.3.0](https://github.com/dry-rb/dry-initializer/compare/v0.2.1..v0.3.0)

### Internals

* Make all instances (Builder and Signature) immutable (@nepalez)
* Decouple mixin from a builder to prevent pollution (@nepalez)
* Ensure default value block can use private variables (@jeremyf)

[Compare v0.2.0...v0.2.1](https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1)

## v0.2.1 2016-05-19

### Bugs Fixed

* Fix polluting superclass with declarations from subclass (@nepalez)

### Internals

* Make all instances (Builder and Signature) immutable (@nepalez)
* Decouple mixin from a builder to prevent pollution (@nepalez)
* Ensure default value block can use private variables (@jeremyf)

[Compare v0.2.0...v0.2.1](https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1)

## v0.2.0 2016-05-16

The gem internals has been rewritten heavily to make the gem pluggable and fix
bugs in "container style". Type constraints were extracted to a plugin
that should be added explicitly.

Small extensions were added to type constraints to support constraint by any
object, and apply value coercion via `dry-types`.

Default assignments became slower (while plain type constraint are not)!

### Changed (backward-incompatible changes)

* Make dry-types constraint to coerce variables (@nepalez)

  ```ruby
  # This will coerce `name: :foo` to `"foo"`
  option :name, type: Dry::Types::Coercible::String
  ```

* Stop supporing proc type constraint (@nepalez)

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

* Support type constraint via every object's case equality (@nepalez)

  ```ruby
  option :name, type: /foo/
  option :name, type: (1..14)
  ```

* Support defaults and type constraints for the "container" syntax (@nepalez)
* Support adding extensions via plugin system (@nepalez)

### Internal

* Private method `##__after_initialize__` is added by the `Mixin` along with `#initialize` (@nepalez)

  The previous implementation required defaults and types to be stored in the class method `.initializer_builder`.
  That made "container" syntax to support neither defaults nor types.

  Now the `#initializer` is still defined via `instance_eval(code)` for efficiency. Some operations
  (like default assignments, coercions, dry-type constraints etc.) cannot be implemented in this way.
  They are made inside `##__after_initialize__` callback, that is biult via `default_method(&block)`
  using instance evals.

[Compare v0.1.1...v0.2.0](https://github.com/dry-rb/dry-initializer/compare/v0.1.1...v0.2.0)

## v0.1.1 2016-04-28

### Added

* `include Dry::Initializer.define -> do .. end` syntax (@flash-gordon)

[Compare v0.1.0...v0.1.1](https://github.com/dry-rb/dry-initializer/compare/v0.1.0...v0.1.1)

## v0.1.0 2016-04-26

Class DSL splitted to mixin and container versions (thanks to @AMHOL for the idea).
Backward compatibility is broken.

### Changed (backward-incompatible changes)

* Use `extend Dry::Initializer::Mixin` instead of `extend Dry::Initializer` (@nepalez)

### Added

* Use `include Dry::Initializer.define(&block)` as an alternative to extending the class (@nepalez)

[Compare v0.0.1...v0.1.0](https://github.com/dry-rb/dry-initializer/compare/v0.0.1...v0.1.0)

## v0.0.1 2016-04-09

First public release
