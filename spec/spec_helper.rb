$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'coveralls'
Coveralls.wear!

if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    command_name 'rspec'
  end
end

require 'lucid'