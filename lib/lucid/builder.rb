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

    def background(background)
      @current_context = Background.new(background)
      @current_feature.backgrounds << @current_context
    end

    def scenario_outline(template)
      @current_context = ScenarioOutline.new(template)
    end

    def step(step)
      step_args = []
      if step.doc_string
        step_args.push(step.doc_string.value)
      end

      if step.rows
        table = Lucid::Table.new(step.rows.map(&:cells).map(&:to_a))
        step_args.push(table)
      end
      @current_context.steps << Step.new(step.keyword, step.name, step.line, step_args)
    end

    def examples(examples)
      @current_feature.scenarios.push(*@current_context.rows_to_scenarios(examples))
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
      attr_reader :backgrounds

      def initialize(repr)
        @repr = repr
        @scenarios = []
        @backgrounds = []
      end
    end

    class Scenario
      include Name
      include Line
      include Tags

      attr_accessor :steps

      def initialize(repr)
        @repr = repr
        @steps = []
      end
    end

    class Background
      include Name
      include Line

      attr_reader :steps

      def initialize(repr)
        @repr = repr
        @steps = []
      end
    end

    class ScenarioOutline
      attr_reader :steps

      def initialize(repr)
        @repr = repr
        @steps = []
      end

      def rows_to_scenarios(examples)
        rows = examples.rows.map(&:cells)
        headers = rows.shift

        rows.map do |row|
          Scenario.new(@repr).tap do |scenario|
            scenario.steps = steps.map do |step|
              name = swap(step.name, headers, row)
              step_args = step.step_args.map do |arg|
                case arg
                  when String
                    swap(arg, headers, rows)
                  when Lucid::Table
                    Lucid::Table.new(arg.map { |arg_row| arg_row.map {|arg_col| swap(arg_col, headers, row)} })
                end
              end
              Step.new(step.keyword, name, step.line, step_args)
            end
          end
        end
      end

      private

      # The parameterized item that is captured from the outline step is
      # stored in $1. When the scenario is created, the specific entry
      # for a row with the name of the captured item will be stored.
      def swap(name, headers, row)
        name.gsub(/<([^>]*)>/) do
          Hash[headers.zip(row)][$1]
        end
      end
    end

    class Step < Struct.new(:keyword, :name, :line, :step_args)
      def to_s
        "#{keyword}#{name}"
      end
    end
  end
end
