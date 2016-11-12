Gem::Specification.new do |gem|
  gem.name     = "dry-initializer"
  gem.version  = "0.10.0"
  gem.author   = ["Vladimir Kochnev (marshall-lee)", "Andrew Kozin (nepalez)"]
  gem.email    = ["hashtable@yandex.ru", "andrew.kozin@gmail.com"]
  gem.homepage = "https://github.com/dryrb/dry-initializer"
  gem.summary  = "DSL for declaring params and options of the initializer"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.2"

  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "dry-types", "~> 0.5", "> 0.5.1"
  gem.add_development_dependency "rubocop", "~> 0.42"
end
