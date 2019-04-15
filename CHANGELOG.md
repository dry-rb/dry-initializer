# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [3.0.1] [2019-04-15]

### Fixed

- Usage of underscored names of `option`-s and `param`-s (nepalez)

  You can use any sequence of underscores except for in nested types.
  In nested types single underscores can be used to split alphanumeric
  parts only.

  ```ruby
  class Test
    extend Dry::Initializer

    # Proper usage
    option :foo_bar do
      option :__foo__, proc(&:to_s)
    end
  end

    # Improper usage
    option :__foo__ do
      # ...
    end

    option :foo__bar do
      # ...
    end
  end
  ```

  This restriction is necessary because we constantize option/param names
  when defining nested structs.

## [3.0.0] [2019-04-14]

### Added

- Support of wrapped types/coercers (nepalez)

  ```ruby
  class Test
    # Wrap type to the array
    param :foo, [proc(&:to_s)]
  end

  # And the value will be wrapped as well
  test = Test.new(42)
  test.foo # => ["42"]
  ```

- It works with several layers of nesting (nepalez)

  ```ruby
  class Test
    # Wrap type to the array
    param :foo, [[proc(&:to_s)]]
  end

  # And the value will be wrapped as well
  test = Test.new(42)
  test.foo # => [["42"]]
  ```

- Support of nested types/coercers (nepalez)

  ```ruby
  class Test
    param :foo do
      option :bar do
        option :baz, proc(&:to_s)
      end
    end
  end

  test = Test.new(bar: { "baz" => 42 })
  test.foo.bar.baz # => "42"
  ```

- Wrapped/nested combinations are supported as well (nepalez)

  ```ruby
  class Test
    param :foo, [] do
      option :bar, proc(&:to_s)
    end
  end

  test = Test.new(bar: 42)
  test.foo.first.bar # => "42"
  ```

## [2.7.0] Unreleazed

### Fixed

- Roll back master to the state of [2.5.0].

  Somehow distinction between `@default_null` and `@null` variables
  in the `Dry::Initializer::Builders` broken the `rom` library.

  The version [2.6.0] has been yanked on rubygems, so the master
  was rolled back to the previous state until the reason for
  the incompatibility become clear (bjeanes, nepalez)

## [2.6.0] [2018-09-09] (YANKED)

## [2.5.0] [2018-08-17]

### Fixed

- `nil` coercion (belousovAV)

  When default value is `nil` instead of `Dry::Initializer::UNDEFINED`,
  the coercion should be applied to any value, including `nil`, because
  we cannot distinct "undefined" `nil` from the "assigned" `nil` value.

## [2.4.0] [2018-02-01]

### Added
- Dispatchers for adding syntax sugar to `param` and `options` (nepalez)

  ```ruby
  # Converts `integer: true` to `type: proc(&:to_i)`
  dispatcher = ->(op) { op[:integer] ? op.merge(type: proc(&:to_i)) : op }
  # Register a dispatcher
  Dry::Initializer::Dispatchers << dispatcher
  # Use syntax sugar
  class User
    param :id, integer: true # same as param :id, proc(&:to_i)
  end
  ```

## [2.3.0] [2017-09-19]

### Added
- Type coercer can take second argument for the initialized instance (nepalez)
  This allows to wrap assigned value to the object that refers back
  to the initializer instance. More verbose example:

  ```ruby
  class Location < String
    attr_reader :parameter # refers back to its parameter
  
    def initialize(name, parameter)
      super(name)
      @parameter = parameter
    end
  end

  class Parameter
    extend Dry::Initializer
    param :name
    param :location, ->(value, param) { Location.new(value, param) }
  end

  offset = Parameter.new "offset", location: "query"
  offset.name     # => "offset"
  offset.location # => "query"
  offset.location.parameter == offset # true
  ```

## [2.2.0] [2017-09-13]

### Added
- Option `:desc` for option/param to add a description (nepalez)

- Methods `Definition#inch` and `Config#inch` to inspect definitions (nepalez)

  ```ruby
  class User
    extend Dry::Initializer
    option :name,  proc(&:to_s), optional: true, desc: "User name"
    option :email, optional: true, desc: "user email"
  end

  User.dry_initializer.inch
  # @!method initialize(*, **options)
  # Initializes an instance of User
  # @option [Object] :name (optional) User name
  # @option [Object] :email (optional) User email
  # @return [User]
  ```

## [2.1.0] [2017-09-11]

### Added
- Method `#options` to param/option definition (nepalez)

  ```ruby
  class User
    extend Dry::Initializer
    option :name,  proc(&:to_s), optional: true
    option :email, optional: true
  end

  User.dry_initializer.options.map do |option|
    [option.source, option.options]
  end
  # => [
  #      [:name,  { type: proc(&:to_s), as: :name, optional: true }],
  #      [:email, { as: :email, optional: true }]
  #    ]
  ```

  This method can be helpful for replicating params/options
  in another class without inheritance.

## [2.0.0] [2017-08-28]

The gem has been rewritten under the hood keeping its documented
interface about the same (see "Deleted" section below for the only
backward-incompatible change).

The main achievement of this version is fixing an edge case where
change in params/options of superclass wasn't reflected in its
previously declared subclasses.

Thanks to @solnic for the idea of class-level container,
and to @gzigzigzeo for persuading me to do this refactoring.

### Deleted
- Undocumented variable `@__option__` which was the main reason for refactoring
  (gzigzigzeo, nepalez).

### Added
- Class method `.dry_initializer` -- a container for `.params` and `.options`
  `.definitions` along with the `.null` setting (either `nil` or `UNDEFINED`)
  used for unassigned values (nepalez)

- `.dry_initializer.attributes` method takes an instance of the same class
  and returns the hash of assigned options. This provide the same
  functionality as previously used instance variable `@__options__` (nepalez)

  ```ruby
  object.class.dry_initializer.attributes(object)
  ```

  When you use "Dry::Initializer.define -> { ... }" syntax,
  the class method `.dry_initializer` is not defined. To access attributes
  you should use private instance method `#__dry_initializer_config__` instead:

  ```ruby
  object.send(:__dry_initializer_config__).attributes(object)
  ```

  Both methods `.dry_initializer` and `#__dry_initializer_config__` refer
  to the same object.

- `.dry_initializer.public_attributes`. This method works differently:
  it looks through (possibly reloaded) readers instead of variables
  (gzigzigzeo, nepalez)

  ```ruby
  object.class.dry_initializer.public_attributes(object)
  ```

  You can use the same trick as above mutatis mutandis.

### Fixed
- Definition order dependency bug (nepalez)

  I've found out that if you provided a subclass and then changed params
  or options of its superclass, these changes woudn't be reflected in
  subclasses until you change any of it params/options as well.

  Now this bug is fixed: every time you call `param` or `option` at
  any class, the gem scans through all its descendants to the very bottom
  of the tree, and reloads their defintitions.

  Being done in load time, the rebuilt makes no effect on runtime performance.

- Possible misbehavior when you define param and option with the same name (nepalez)

  Doing this will provide `option :name` only, not both:

  ```ruby
  param  :name
  option :name
  ```

- Attempt to redefine param/option of superclass with option/param in
  its subclass will cause an exception because it would break
  Liskov substitute principle with unexpected behaviour (nepalez)

  No, you can do neither these definitions, nor vice versa:

  ```ruby
  class Foo
    extend Dry::Intitializer
    param :name
  end

  class Bar < Foo
    option :name
  end
  ```

- When you reloading previously defined param of superclass, the gem
  will check all its descendands for whether all required positional params
  goes before optional ones (nepalez)

  ```ruby
  class Foo
    param :name
    # Foo: def initializer(name)
  end

  class Bar
    param :email
    # Bar: def initializer(name, email)
  end

  class Foo
    # This raises SyntaxError because in Bar this would cause wrong definition
    # Foo: def initializer(name = nil)
    # Bar: def initializer(name = nil, email)
    param :name, optional: true
  end
  ```

### Changed
- Under the hood I've separated param/option settings declaration (a container
  with param/option settings) from code builders for initializer and readers
  (nepalez)

  You can check both the code for the `__initializer__`:

  ```ruby
  class Foo
    extend Dry::Initializer
    # ...
  end

  Foo.dry_initializer.code
  ```

  and readers:

  ```ruby
  Foo.dry_initializer.params.map(&:code)
  Foo.dry_initializer.options.map(&:code)

  # or

  Foo.dry_initializer.definitions.values.map(&:code)
  ```

  You can also check settings for every param and option using methods
  `dry_initializer.params`, `dry_initializer.options` (lists), or
  `dry_initializer.definitions` (hash).

  You can check null value via `.dry_initializer.null` which is different
  for `Dry::Initializer` and `Dry::Initializer[undefined: false]` modules.

- Optimized the code for `__initializer__`-s (the method where all magics occurs)
  (nepalez)

  Benchmarks remained about the same:

  ```shell
  rake benchmark
  ```

  ```
  Benchmark for instantiation with plain params
          value_struct:  4317196.9 i/s
            plain Ruby:  4129803.9 i/s - 1.05x  slower
       dry-initializer:  1710702.1 i/s - 2.52x  slower
               concord:  1372630.4 i/s - 3.15x  slower
                values:   601651.8 i/s - 7.18x  slower
           attr_extras:   535599.5 i/s - 8.06x  slower
  ```

  ```
  Benchmark for instantiation with plain options
            plain Ruby: 1769174.1 i/s
       dry-initializer:  636634.1 i/s - 2.78x  slower
                kwattr:  423296.5 i/s - 4.18x  slower
                 anima:  399415.0 i/s - 4.43x  slower
  ```

  ```
  Benchmark for instantiation with coercion
            plain Ruby:  1565501.0 i/s
       fast_attributes:   569952.9 i/s -  2.75x  slower
       dry-initializer:   461122.1 i/s -  3.39x  slower
                virtus:   138074.8 i/s - 11.34x  slower
  ```

  ```
  Benchmark for instantiation with default values
            plain Ruby:  3402455.4 i/s
                kwattr:   586206.5 i/s -  5.80x  slower
       dry-initializer:   528482.2 i/s -  6.44x  slower
           active_attr:   298697.7 i/s - 11.39x  slower
  ```

  ```
  Benchmark for instantiation with type constraints and default values
            plain Ruby: 2881696.1 i/s
       dry-initializer:  470815.1 i/s -  6.12x  slower
                virtus:  180272.6 i/s - 15.99x  slower
  ```

## [1.4.1] [2017-04-05]

### Fixed
- Warning about redefined `#initialize` in case the method reloaded in a klass
  that extends the module (nepalez, sergey-chechaev)

### Changed
- Rename `Dry::Initializer::DSL` -> `Dry::Initializer::ClassDSL` (nepalez)
- Add `Dry::Initializer::InstanceDSL` (nepalez)

### Deprecated
- `Dry::Initializer::Mixin`. In latest version this was an alias for
  `Dry::Initializer` that kept for backward compatibility for early versions of the gem.

  This story will come to the end in `v2.1.0`.

## [1.4.0] [2017-03-08]

### Changed (backward-incompatible)
- The `@__options__` hash now collects all assigned attributes,
  collected via `#option` (as before), and `#param` (nepalez)

## [1.3.0] [2017-03-05]

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

### Changed
- Fixed method definitions for performance at the load time (nepalez, flash-gordon)

## [1.2.0] [2017-03-05]

### Fixed
- The `@__options__` variable collects renamed options after default values and coercions were applied (nepalez)

## [1.1.3] [2017-03-01]

### Added
- Support for lambdas as default values (nepalez, gzigzigzeo)

## [1.1.2] [2017-02-06]

### Changed
- Remove previously defined methods before redefining them (flash-gordon)

## [1.1.1] [2017-02-04]

### Fixed
- `@__options__` collects defined options only (nepalez)

## [1.1.0] [2017-01-28]

### Added
- enhancement via `Dry::Initializer::Attribute.dispatchers` registry (nepalez)

  ```ruby
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
  ```

### Changed
- optimize assignments for performance (nepalez)

## [1.0.0] [2017-01-22]

In this version the code has been rewritten for simplicity

### Changed
- [BREAKING] when `param` or `option` was not defined, the corresponding **variable** is set to `Dry::Initializer::UNDEFINED`, but the **reader** (when defined) will return `nil` (nepalez)

- `Dry::Initializer` and `Dry::Initializer::Mixin` became aliases (nepalez)

### Added
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

## [0.11.0] [2017-01-02]

### Added
- Support of reloading `#initializer` with `super` (nepalez)

### Internal
- Refactor the way [#initializer] method is (re)defined (nepalez)
  
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

## [0.10.2] [2016-12-31]

### Added
- Support of Ruby 2.4 (flas-gordon)

### Internal
- Code clearance for ROM integration (flash-gordon)

## [0.10.1] [2016-12-27]

### Fixed
- Wrong arity when there were no options and the last param had a default (nolith)

## [0.10.0] [2016-11-20]

### Deleted (BREAKING CHANGE!)
- Deprecated method DSL#using (nepalez)

## [0.9.3] [2016-11-20]

### Deprecated
- After discussion in [PR #17]: https://github.com/dry-rb/dry-initializer/pull/17)
  (many thanks to @sahal2080 and @hrom512 for starting that issue and PR),
  the method `using` is deprecated and will be removed from v0.10.0 (nepalez)

### Fixed
- Support of weird option names (nepalez)

  ```ruby
  option :"First name", as: :first_name
  ```

## [0.9.2] [2016-11-10]

### Fixed
- Validation of attributes (params and options) (nepalez)

## [0.9.1] [2016-11-06]

### Added
- Support for renaming an option during initialization (nepalez)

  option :name, as: :username # to take :name option and create :username attribute

## [0.9.0] [2016-11-06]

### Added
- The method `#initialize` is defined when a class extended the module (nepalez)

  In previous versions the method was defined only by `param` and `option` calls.

### Breaking Changes
- The initializer accepts any option (but skips unknown) from the very beginning (nepalez)

### Deleted
- Deprecated methods `tolerant_to_unknown_options` and `intolerant_to_unknown_options` (nepalez)

### Internal
- Refactor scope (`using`) to support methods renaming and aliasing (nepalez)

## [0.8.1] [2016-11-05]

### Added
- Support for `dry-struct`ish syntax for constraints (type as a second parameter) (nepalez)

    option :name, Dry::Types['strict.string']

## [0.8.0] [2016-11-05]

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
- support for special options like `option :end`, `option :begin` etc. (nepalez)

### Changed
- switched from key arguments to serialized hash argument in the initializer (nepalez)

### Breaking Changes
- the initializer becomes tolerant to unknown options when any `option` was set,
  ignoring `intolerant_to_unknown_options` helper.

- the initializer becomes intolerant to options when no `option` was set,
  ignoring `tolerant_to_unknown_options` helper.

### Deprecated
- `tolerant_to_unknown_options`
- `intolerant_to_unknown_options`

## [0.7.0] [2016-10-11]

### Added
- Shared settings with `#using` method (nepalez)

## [0.6.0] [2016-10-09]

### Added
- Support for private and protected readers in the `reader:` option (jmgarnier)

## [0.5.0] [2016-08-21]

### Added
- Allow `optional` attribute to be left undefined (nepalez)

## [0.4.0] [2016-05-28]

### Deleted (backward-incompatible changes)
- Support of modules and case equality as type constraints (nepalez)

## [0.3.3] [2016-05-28]

- Add deprecation warnings about modules and case equality as type constraints (nepalez)

## [0.3.2] [2016-05-25]

### Fixed
- Add explicit requirement for ruby 'set' (rickenharp)

## [0.3.1] [2016-05-22]

### Added
- Support for tolerance to unknown options (nepalez)

## [0.3.0] [2016-05-19]

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
- Made Mixin##initializer_builder method private (nepalez)
- Add Mixin#register_initializer_plugin(plugin) method (nepalez)

### Fixed
- Prevent plugin's registry from polluting superclass (nepalez)

### Changed
- Make all instances (Builder and Signature) immutable (nepalez)
- Decouple mixin from a builder to prevent pollution (nepalez)
- Ensure default value block can use private variables (jeremyf)

## [0.2.1] [2016-05-19]

### Fixed
- Fix polluting superclass with declarations from subclass (nepalez)

### Changed
- Make all instances (Builder and Signature) immutable (nepalez)
- Decouple mixin from a builder to prevent pollution (nepalez)
- Ensure default value block can use private variables (jeremyf)

## [0.2.0] [2016-05-16]

The gem internals has been rewritten heavily to make the gem pluggable and fix
bugs in "container style". Type constraints were extracted to a plugin
that should be added explicitly.

Small extensions were added to type constraints to support constraint by any
object, and apply value coercion via `dry-types`.

Default assignments became slower (while plain type constraint are not)!

### Changed (backward-incompatible changes)
- Make dry-types constraint to coerce variables (nepalez)

  ```ruby
  # This will coerce `name: :foo` to `"foo"`
  option :name, type: Dry::Types::Coercible::String
  ```

- Stop supporing proc type constraint (nepalez)

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
- Support type constraint via every object's case equality (nepalez)

  ```ruby
  option :name, type: /foo/
  option :name, type: (1...14)
  ```

- Support defaults and type constraints for the "container" syntax (nepalez)
- Support adding extensions via plugin system (nepalez)

### Internal
- Private method `##__after_initialize__` is added by the `Mixin` along with `#initialize` (nepalez)

  The previous implementation required defaults and types to be stored in the class method `.initializer_builder`.
  That made "container" syntax to support neither defaults nor types.

  Now the `#initializer` is still defined via `instance_eval(code)` for efficiency. Some operations
  (like default assignments, coercions, dry-type constraints etc.) cannot be implemented in this way.
  They are made inside `##__after_initialize__` callback, that is biult via `default_method(&block)`
  using instance evals.

## [0.1.1] [2016-04-28]

### Added
- `include Dry::Initializer.define -> do ... end` syntax (flash-gordon)

## [0.1.0] [2016-04-26]

Class DSL splitted to mixin and container versions (thanks to @AMHOL for the idea).
Backward compatibility is broken.

### Changed (backward-incompatible changes)
- Use `extend Dry::Initializer::Mixin` instead of `extend Dry::Initializer` (nepalez)

### Added
- Use `include Dry::Initializer.define(&block)` as an alternative to extending the class (nepalez)

## [0.0.1] [2016-04-09]

First public release

[0.1.0]: https://github.com/dry-rb/dry-initializer/compare/v0.0.1...v0.1.0
[0.1.1]: https://github.com/dry-rb/dry-initializer/compare/v0.1.0...v0.1.1
[0.2.0]: https://github.com/dry-rb/dry-initializer/compare/v0.1.1...v0.2.0
[0.2.1]: https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1
[0.2.1]: https://github.com/dry-rb/dry-initializer/compare/v0.2.0...v0.2.1
[0.3.0]: https://github.com/dry-rb/dry-initializer/compare/v0.2.1...v0.3.0
[0.3.1]: https://github.com/dry-rb/dry-initializer/compare/v0.3.0...v0.3.1
[0.3.2]: https://github.com/dry-rb/dry-initializer/compare/v0.3.1...v0.3.2
[0.3.3]: https://github.com/dry-rb/dry-initializer/compare/v0.3.2...v0.3.3
[0.4.0]: https://github.com/dry-rb/dry-initializer/compare/v0.3.3...v0.4.0
[0.5.0]: https://github.com/dry-rb/dry-initializer/compare/v0.4.0...v0.5.0
[0.6.0]: https://github.com/dry-rb/dry-initializer/compare/v0.5.0...v0.6.0
[0.7.0]: https://github.com/dry-rb/dry-initializer/compare/v0.6.0...v0.7.0
[0.8.0]: https://github.com/dry-rb/dry-initializer/compare/v0.7.0...v0.8.0
[0.8.1]: https://github.com/dry-rb/dry-initializer/compare/v0.8.0...v0.8.1
[0.9.0]: https://github.com/dry-rb/dry-initializer/compare/v0.8.1...v0.9.0
[0.9.1]: https://github.com/dry-rb/dry-initializer/compare/v0.9.0...v0.9.1
[0.9.2]: https://github.com/dry-rb/dry-initializer/compare/v0.9.1...v0.9.2
[0.9.3]: https://github.com/dry-rb/dry-initializer/compare/v0.9.2...v0.9.3
[0.10.0]: https://github.com/dry-rb/dry-initializer/compare/v0.9.3...v0.10.0
[0.10.1]: https://github.com/dry-rb/dry-initializer/compare/v0.10.0...v0.10.1
[0.10.2]: https://github.com/dry-rb/dry-initializer/compare/v0.10.1...v0.10.2
[0.11.0]: https://github.com/dry-rb/dry-initializer/compare/v0.10.2...v0.11.0
[1.0.0]: https://github.com/dry-rb/dry-initializer/compare/v0.11.0...v1.0.0
[1.1.0]: https://github.com/dry-rb/dry-initializer/compare/v1.0.0...v1.1.0
[1.1.1]: https://github.com/dry-rb/dry-initializer/compare/v1.1.0...v1.1.1
[1.1.2]: https://github.com/dry-rb/dry-initializer/compare/v1.1.1...v1.1.2
[1.1.3]: https://github.com/dry-rb/dry-initializer/compare/v1.1.2...v1.1.3
[1.2.0]: https://github.com/dry-rb/dry-initializer/compare/v1.1.3...v1.2.0
[1.3.0]: https://github.com/dry-rb/dry-initializer/compare/v1.2.0...v1.3.0
[1.4.0]: https://github.com/dry-rb/dry-initializer/compare/v1.3.0...v1.4.0
[1.4.1]: https://github.com/dry-rb/dry-initializer/compare/v1.4.0...v1.4.1
[2.0.0]: https://github.com/dry-rb/dry-initializer/compare/v1.4.1...v2.0.0
[2.1.0]: https://github.com/dry-rb/dry-initializer/compare/v2.0.0...v2.1.0
[2.2.0]: https://github.com/dry-rb/dry-initializer/compare/v2.1.0...v2.2.0
[2.3.0]: https://github.com/dry-rb/dry-initializer/compare/v2.2.0...v2.3.0
[2.4.0]: https://github.com/dry-rb/dry-initializer/compare/v2.3.0...v2.4.0
[2.6.0]: https://github.com/dry-rb/dry-initializer/compare/v2.4.0...v2.5.0
[2.6.0]: https://github.com/dry-rb/dry-initializer/compare/v2.5.0...v2.6.0
[3.0.0]: https://github.com/dry-rb/dry-initializer/compare/v2.5.0...v3.0.0
[3.0.1]: https://github.com/dry-rb/dry-initializer/compare/v3.0.0...v3.0.1
