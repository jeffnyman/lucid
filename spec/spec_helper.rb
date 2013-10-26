$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 90
  SimpleCov.maximum_coverage_drop 5
end

=begin
if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    command_name 'rspec'
  end
end
=end

require 'lucid'