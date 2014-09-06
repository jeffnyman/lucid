require 'lucid'
require 'pp'

module Lucid
  module RSpec
    class << self
      def build_and_run(test_spec)
        # The call to build() will return an instance that contains a
        # specs instance variable. That, in turn, will contain a
        # representation of the test spec that was processed. That
        # will be a Feature implementation, since a Feature is how
        # Gherkin represents a test spec.
        Lucid::Builder.build(test_spec).specs.each do |feature|
          (puts 'SPEC:'; pp feature) if ENV['LUCID_TRACE']
          ::RSpec.describe feature.name do

            feature.scenarios.each do |scenario|
              (puts 'SCENARIO:'; pp scenario) if ENV['LUCID_TRACE']
              describe scenario.name do
                scenario.steps.each do |step|
                  (puts 'STEP:'; pp step) if ENV['LUCID_TRACE']
                  it step do
                    run(test_spec, step)
                  end
                end
              end
            end

          end
        end
      end
    end

    module SpecLoader
      # @param files [Array] test specs to be executed
      def load(*files, &block)
        puts "Loading: #{files}" if ENV['LUCID_TRACE']

        if files.first.end_with?('.feature','.spec','.story')
          Lucid::RSpec.build_and_run(files.first)
        else
          super
        end
      end
    end

    module SpecRunner
      include Lucid::StepRunner

      # @param test_spec [String] full path for test spec
      # @param step [Struct Lucid::Builder::Step] the step to execute
      def run(test_spec, step)
        step(step)
      end
    end
  end
end

RSpec::Core::Configuration.send(:include, Lucid::RSpec::SpecLoader)

RSpec.configure do |config|
  config.include Lucid::RSpec::SpecRunner
  config.pattern << ',**/*.feature,**/*.spec,**/*.story'
end
