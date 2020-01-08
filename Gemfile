source 'https://rubygems.org'

eval_gemfile 'Gemfile.devtools'

gemspec

if ENV['DRY_TYPES_FROM_MASTER'].eql?('true')
  gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'
else
  gem 'dry-types'
end

group :benchmarks do
  if RUBY_VERSION < '2.4'
    gem 'activesupport', '< 5'
  else
    gem 'activesupport'
  end

  gem 'active_attr'
  gem 'anima'
  gem 'attr_extras'
  gem 'benchmark-ips', '~> 2.5'
  gem 'concord'
  gem 'fast_attributes'
  gem 'kwattr'
  gem 'ruby-prof', platform: :mri
  gem 'value_struct'
  gem 'values'
  gem 'virtus'
end

group :development, :test do
  gem 'pry', platform: :mri
  gem 'pry-byebug', platform: :mri
end
