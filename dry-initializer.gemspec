require File.expand_path('lib/dry/initializer/version', __dir__)

Gem::Specification.new do |gem|
  gem.name     = 'dry-initializer'
  gem.version  = Dry::Initializer::VERSION
  gem.author   = ['Vladimir Kochnev (marshall-lee)', 'Andrew Kozin (nepalez)']
  gem.email    = 'andrew.kozin@gmail.com'
  gem.homepage = 'https://github.com/dry-rb/dry-initializer'
  gem.summary  = 'DSL for declaring params and options of the initializer'
  gem.license  = 'MIT'

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir['README.md', 'LICENSE', 'CHANGELOG.md']

  gem.required_ruby_version = '>= 2.3'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rake', '> 10'
end
