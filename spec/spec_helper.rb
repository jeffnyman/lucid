$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'coveralls'
Coveralls.wear!

SimpleCov.add_filter '/spec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 60
  SimpleCov.maximum_coverage_drop 5
end

require 'lucid'