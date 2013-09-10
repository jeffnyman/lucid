require 'lucid/cli/app'
require 'lucent/steps'
require 'lucent/tester'

Before do
  Lucent::Tester.app_class = Lucid::CLI::App
  Lucent.process = Lucent::Tester
end