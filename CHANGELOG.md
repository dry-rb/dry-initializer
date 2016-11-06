## v0.9.0 2016-11-06

### Added

* The method `#initialize` is defined when a class extended the module (@nepalez)

  In previous versions the method was defined only by `param` and `option` calls.

### Breaking Changes

* The initializer accepts any option (but skips unknown) from the very beginning (@nepalez)

### Deleted

* Deprecated methods `tolerant_to_unknown_options` and `intolerant_to_unknown_options` (@nepalez)

### Internal

* Refactor scope (`using`) to support methods renaming and aliasing (@nepalez)

[Compare 0.8.1...v0.9.0](https://github.com/dry-rb/dry-initializer/compare/0.8.1...v0.9.0)

## v0.8.1 2016-11-05

### Added

* Support for `dry-struct`ish syntax for constraints (type as a second parameter) (@nepalez)

    option :name, Dry::Types['strict.string']

[Compare v0.8.0...0.8.1](https://github.com/dry-rb/dry-initializer/compare/v0.8.0..0.8.1)

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

* support for special options like `option :end`, `option :begin` etc. (@nepalez)

### Internals

* switched from key arguments to serialized hash argument in the initializer (@nepalez)

### Breaking Changes

* the initializer becomes tolerant to unknown options when any `option` was set,
  ignoring `intolerant_to_unknown_options` helper.

* the initializer becomes intolerant to options when no `option` was set,
  ignoring `tolerant_to_unknown_options` helper.

### Deprecated

* `tolerant_to_unknown_options`
* `intolerant_to_unknown_options`

[Compare v0.7.0...v0.8.0](https://github.com/dry-rb/dry-initializer/compare/v0.7.0..v0.8.0)

## v0.7.0 2016-10-11

### Added

* Shared settings with `#using` method (@nepalez)

[Compare v0.6.0...v0.7.0](https://github.com/dry-rb/dry-initializer/compare/v0.6.0..v0.7.0)

## v0.6.0 2016-10-09

### Added

* Support for private and protected readers in the `reader:` option (@jmgarnier)

[Compare v0.5.0...v0.6.0](https://github.com/dry-rb/dry-initializer/compare/v0.5.0..v0.6.0)

## v0.5.0 2016-08-21

### Added

* Allow `optional` attribute to be left undefined (@nepalez)

[Compare v0.4.0...v0.5.0](https://github.com/dry-rb/dry-initializer/compare/v0.4.0..v0.5.0)

## v0.4.0 2016-05-28

### Deleted (backward-incompatible changes)

* Support of modules and case equality as type constraints (@nepalez)

[Compare v0.3.3...v0.4.0](https://github.com/dry-rb/dry-initializer/compare/v0.3.3..v0.4.0)

## v0.3.3 2016-05-28

* Add deprecation warnings about modules and case equality as type constraints (@nepalez)

[Compare v0.3.2...v0.3.3](https://github.com/dry-rb/dry-initializer/compare/v0.3.2..v0.3.3)

## v0.3.2 2016-05-25

### Bugs Fixed

* Add explicit requirement for ruby 'set' (@rickenharp)

[Compare v0.3.1...v0.3.2](https://github.com/dry-rb/dry-initializer/compare/v0.3.1..v0.3.2)

## v0.3.1 2016-05-22

### Added

* Support for tolerance to unknown options (@nepalez)

[Compare v0.3.0...v0.3.1](https://github.com/dry-rb/dry-initializer/compare/v0.3.0..v0.3.1)

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
