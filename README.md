# dry-initializer [![Join the chat at https://dry-rb.zulipchat.com](https://img.shields.io/badge/dry--rb-join%20chat-%23346b7a.svg)][chat]

[![Gem Version](https://badge.fury.io/rb/dry-initializer.svg)][gem]
[![Build Status](https://github.com/dry-rb/dry-initializer/workflows/ci/badge.svg)][ci]
[![Code Climate](https://codeclimate.com/github/dry-rb/dry-initializer/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://api.codeclimate.com/v1/badges/73cb64231f3fb2c86e26/test_coverage)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dry-rb/dry-initializer.svg?branch=master)][inchpages]

[gem]: https://rubygems.org/gems/dry-initializer
[ci]: https://github.com/dry-rb/dry-initializer/actions?query=workflow%3Aci
[codeclimate]: https://codeclimate.com/github/dry-rb/dry-initializer
[coveralls]: https://coveralls.io/r/dry-rb/dry-initializer
[inchpages]: http://inch-ci.org/github/dry-rb/dry-initializer
[docs]: http://dry-rb.org/gems/dry-initializer/
[benchmarks]: https://github.com/dry-rb/dry-initializer/wiki
[license]: http://opensource.org/licenses/MIT
[chat]: https://dry-rb.zulipchat.com

DSL for building class initializer with params and options.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-initializer'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install dry-initializer
```

## Synopsis

```ruby
require 'dry-initializer'
require 'dry-types'

class User
  extend Dry::Initializer

  # Params of the initializer along with corresponding readers
  param  :name,  proc(&:to_s)
  param  :role,  default: -> { 'customer' }
  # Options of the initializer along with corresponding readers
  option :admin, default: -> { false }
  option :vip,   optional: true
end

# Defines the initializer with params and options
user = User.new 'Vladimir', 'admin', admin: true

# Defines readers for single attributes
user.name  # => 'Vladimir'
user.role  # => 'admin'
user.admin # => true
user.vip   # => Dry::Initializer::UNDEFINED
```

See full documentation on the [Dry project official site][docs]

## Benchmarks

The `dry-initializer` is pretty fast for rubies 2.3+ [comparing to other libraries][benchmarks].

## Compatibility

Tested under rubies [compatible to MRI 2.3+](.travis.yml).

## Contributing

- [Fork the project](https://github.com/dry-rb/dry-initializer)
- Create your feature branch (`git checkout -b my-new-feature`)
- Add tests for it
- Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License][license].
