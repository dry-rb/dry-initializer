# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

if ENV["DRY_TYPES_FROM_MASTER"].eql?("true")
  gem "dry-types", github: "dry-rb/dry-types", branch: "master"
else
  gem "dry-types"
end

group :benchmarks do
  gem "active_attr"
  gem "activesupport"
  gem "anima"
  gem "attr_extras"
  gem "benchmark-ips", "~> 2.5"
  gem "concord"
  gem "fast_attributes"
  gem "kwattr"
  gem "ruby-prof", platform: :mri
  gem "values"
  gem "value_struct"
  gem "virtus"
end
