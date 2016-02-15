source "https://rubygems.org"

# Specify your gem"s dependencies in dry-initializer.gemspec
gemspec

gem "dry-types", git: "https://github.com/dryrb/dry-types", branch: "master"

group :benchmarks do
  gem "benchmark-ips", "~> 2.5"

  gem "active_attr"
  gem "anima"
  gem "attr_extras"
  gem "concord"
  gem "fast_attributes"
  gem "kwattr"
  gem "value_struct"
  gem "values"
  gem "virtus"
end

group :development, :test do
  gem "pry", platform: :mri
  gem "pry-byebug", platform: :mri
end
