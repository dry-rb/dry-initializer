source "https://rubygems.org"

# Specify your gem"s dependencies in dry-initializer.gemspec
gemspec

group :benchmarks do
  if RUBY_VERSION < "2.4"
    gem "activesupport", "< 5"
  else
    gem "activesupport"
  end

  gem "active_attr"
  gem "anima"
  gem "attr_extras"
  gem "benchmark-ips", "~> 2.5"
  gem "concord"
  gem "fast_attributes"
  gem "kwattr"
  gem "ruby-prof", platform: :mri
  gem "value_struct"
  gem "values"
  gem "virtus"
end

group :development, :test do
  gem "pry", platform: :mri
  gem "pry-byebug", platform: :mri
end
