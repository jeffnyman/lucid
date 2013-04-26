# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

###$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/platform"

Gem::Specification.new do |gem|
  gem.name        = 'lucid'
  gem.version     = Cucumber::VERSION
  gem.authors     = ["Jeff Nyman"]
  gem.description = 'Test Description Language Execution Engine'
  gem.summary     = "lucid-#{gem.version}"
  gem.email       = ["jeffnyman@gmail.com"]
  gem.license     = "MIT"
  gem.homepage    = "https://github.com/jnyman/lucid"
  gem.platform    = Gem::Platform::RUBY
  
  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency 'builder', '>= 2.1.2'
  gem.add_dependency 'diff-lcs', '>= 1.1.3'
  gem.add_dependency 'gherkin', '~> 2.12.0'
  gem.add_dependency 'multi_json', '~> 1.3'

  gem.add_development_dependency 'aruba', '~> 0.5.2'
  gem.add_development_dependency 'json', '~> 1.7'
  gem.add_development_dependency 'nokogiri', '>= 1.5.2'
  gem.add_development_dependency 'rake', '>= 0.9.2'
  gem.add_development_dependency 'rspec', '>= 2.13'
  gem.add_development_dependency 'simplecov', '>= 0.6.2'
  gem.add_development_dependency 'spork', '>= 1.0.0.rc2'
  gem.add_development_dependency 'syntax', '>= 1.0.0'

  # For Documentation:
  gem.add_development_dependency 'bcat', '~> 0.6.2'
  gem.add_development_dependency 'kramdown', '~> 0.14'
  gem.add_development_dependency 'yard', '~> 0.8.0'

  # Needed for examples (rake examples)
  gem.add_development_dependency 'capybara', '>= 2.1'
  gem.add_development_dependency 'rack-test', '>= 0.6.1'
  gem.add_development_dependency 'sinatra', '>= 1.3.2'

  gem.rubygems_version = ">= 1.6.1"
  gem.files            = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  gem.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  gem.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.rdoc_options     = ["--charset=UTF-8"]
  gem.require_paths    = ["lib"]
end
