$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov'
require 'coveralls'

Coveralls.wear!

SimpleCov.add_filter '/spec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec'
  coverage_dir "#{SimpleCov.root}/spec/reports/coverage"
  minimum_coverage 70
  maximum_coverage_drop 5
end

require 'lucid'
