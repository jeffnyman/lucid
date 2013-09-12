$LOAD_PATH.unshift(File.dirname(__FILE__))

if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    command_name 'rspec'
  end
end

require 'lucid'