require 'gherkin'

module Lucid
  class Builder
    class << self
      def build(test_spec)
        Lucid::Builder.new.tap do |builder|
          # Builder instance is yielded to the block.
          # The builder is used as the "formatter" to the Gherkin parser.
          # The builder instance is then returned to the rspec loader.
          parser = Gherkin::Parser::Parser.new(builder, true)
          parser.parse(File.read(test_spec), test_spec, 0)
        end
      end
    end

    attr_reader :specs

    def initialize
      @specs = []
    end

    # Gherkin API Methods

    def uri(*)
    end

    def eof
    end

    def feature(feature)
      @current_feature = Feature.new(feature)
      @specs << @current_feature
    end

    def scenario(scenario)
      @current_context = Scenario.new(scenario)
      @current_feature.scenarios << @current_context
    end

    def step(step)
      @current_context.steps << Step.new(step.keyword, step.name, step.line)
    end

    # Test Spec Gherkin Objects

    module Name
      def name
        @repr.name
      end
    end

    module Line
      def line
        @repr.line
      end
    end

    module Tags
      def tags
        @repr.tags.map { |tag| tag.name.sub(/^@/, '')}
      end
    end

    class Feature
      include Name
      include Line
      include Tags

      attr_reader :scenarios

      def initialize(repr)
        @repr = repr
        @scenarios = []
      end
    end

    class Scenario
      include Name
      include Line
      include Tags

      attr_reader :steps

      def initialize(repr)
        @repr = repr
        @steps = []
      end
    end

    class Step < Struct.new(:keyword, :name, :line)
      def to_s
        "#{keyword}#{name}"
      end
    end
  end
end
