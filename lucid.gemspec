# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lucid/version'

Gem::Specification.new do |gem|
  gem.name          = "lucid"
  gem.version       = Lucid::VERSION
  gem.authors       = ["Jeff Nyman"]
  gem.email         = ["jeffnyman@gmail.com"]
  gem.license       = "MIT"
  gem.description   = %q{Execution Wrapper for Cucumber}
  gem.summary       = %q{Execution Wrapper for Cucumber}
  gem.homepage      = "https://github.com/jnyman/lucid"
  
  gem.required_ruby_version = '>= 1.9.2'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
