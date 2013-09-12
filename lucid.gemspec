# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "lucid/platform"

Gem::Specification.new do |gem|
  gem.name        = 'lucid'
  gem.version     = Lucid::VERSION
  gem.authors     = ["Jeff Nyman"]
  gem.description = 'Test Description Language Execution Engine'
  gem.summary     = "lucid-#{gem.version}"
  gem.email       = ['jeffnyman@gmail.com']
  gem.license     = 'MIT'
  gem.homepage    = 'https://github.com/jnyman/lucid'
  gem.platform    = Gem::Platform::RUBY
  
  gem.required_ruby_version = '>= 1.9.3'
  gem.rubygems_version      = '>= 1.6.1'

  gem.add_runtime_dependency 'thor', '>= 0.18.1'
  gem.add_runtime_dependency 'builder', '>= 2.1.2'
  gem.add_runtime_dependency 'diff-lcs', '>= 1.1.3'
  gem.add_runtime_dependency 'gherkin', '~> 2.12.0'
  gem.add_runtime_dependency 'multi_json', '~> 1.7.5'

  gem.post_install_message = %{
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

  Thanks for installing Lucid #{Lucid::VERSION}.

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)
  }

  gem.files            = `git ls-files`.split($/)
  gem.test_files       = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables      = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.rdoc_options     = ["--charset=UTF-8"]
  gem.require_paths    = ["lib"]
end
