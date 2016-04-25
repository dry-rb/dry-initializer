## v0.1.0 2016-04-26

Class DSL splitted to mixin and container versions (thanks to @AMHOL for the idea).
Backward compatibility is broken.

### Changed (backward-incompatible changes)

* Use `extend Dry::Initializer::Mixin` instead of `extend Dry::Initializer` (nepalez)

### Added

* Use `include Dry::Initializer.define(&block)` as an alternative to extending the class (nepalez)

## v0.0.1 2016-04-09

First public release
