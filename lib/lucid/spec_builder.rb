require 'lucid/ast'
require 'gherkin/rubify'
require 'lucid/ast/multiline_argument'
require 'lucid/ast/empty_background'

module Lucid
  module Parser
    # The SpecBuilder conforms to the Gherkin event API.
    class SpecBuilder
      include Gherkin::Rubify

      def initialize(path = 'UNKNOWN-FILE')
        @path = path
      end

      def result
        return nil unless @feature_builder
        @feature_builder.result(language)
      end

      def language=(language)
        @language = language
      end

      def uri(uri)
        @path = uri
      end

      def feature(node)
        @feature_builder = FeatureBuilder.new(file, node)
      end

      def background(node)
        builder = BackgroundBuilder.new(file, node)
        @feature_builder.background_builder = builder
        @current = builder
      end

      def scenario(node)
        builder = ScenarioBuilder.new(file, node)
        @feature_builder.add_child builder
        @current = builder
      end

      def scenario_outline(node)
        builder = ScenarioOutlineBuilder.new(file, node)
        @feature_builder.add_child builder
        @current = builder
      end

      def examples(examples)
        examples_fields = [
          AST::Location.new(file, examples.line),
          AST::Comment.new(examples.comments.map{|comment| comment.value}.join("\n")),
          examples.keyword,
          examples.name,
          examples.description,
          matrix(examples.rows)
        ]
        @current.add_examples examples_fields, examples
      end

      def step(node)
        builder = StepBuilder.new(file, node)
        @current.add_child builder
      end

      def eof
      end

      def syntax_error(state, event, legal_events, line)
        # raise "SYNTAX ERROR"
      end

      private

      if defined?(JRUBY_VERSION)
        java_import java.util.ArrayList
        ArrayList.__persistent__ = true
      end

      def matrix(gherkin_table)
        gherkin_table.map do |gherkin_row|
          row = gherkin_row.cells
          class << row
            attr_accessor :line
          end
          row.line = gherkin_row.line
          row
        end
      end

      def language
        @language || raise("Language has not been set")
      end

      def file
        if Lucid::WINDOWS && !ENV['LUCID_FORWARD_SLASH_PATHS']
          @path.gsub(/\//, '\\')
        else
          @path
        end
      end

      class Spec
        def initialize(file, node)
          @file, @node = file, node
        end

        private

        def tags
          AST::Tags.new(nil, node.tags)
        end

        def location
          AST::Location.new(file, node.line)
        end

        def comment
          AST::Comment.new(node.comments.map{ |comment| comment.value }.join("\n"))
        end

        attr_reader :file, :node
      end

      class FeatureBuilder < Spec
        def result(language)
          background = background(language)
          feature = AST::Feature.new(
            location,
            background,
            comment,
            tags,
            node.keyword,
            node.name.lstrip,
            node.description.rstrip,
            children.map { |builder| builder.result(background, language, tags) }
          )
          feature.gherkin_statement(node)
          feature.language = language
          feature
        end

        def background_builder=(builder)
          @background_builder = builder
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

        private

        def background(language)
          return AST::EmptyBackground.new unless @background_builder
          @background ||= @background_builder.result(language)
        end
      end

      class BackgroundBuilder < Spec
        def result(language)
          background = AST::Background.new(
            language,
            location,
            comment,
            node.keyword,
            node.name,
            node.description,
            steps(language)
          )
          background.gherkin_statement(node)
          background
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

      end

      class ScenarioBuilder < Spec
        def result(background, language, feature_tags)
          scenario = AST::Scenario.new(
            language,
            location,
            background,
            comment,
            tags,
            feature_tags,
            node.keyword,
            node.name,
            node.description,
            steps(language)
          )
          scenario.gherkin_statement(node)
          scenario
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end
      end

      class ScenarioOutlineBuilder < Spec
        def result(background, language, feature_tags)
          scenario_outline = AST::ScenarioOutline.new(
            language,
            location,
            background,
            comment,
            tags,
            feature_tags,
            node.keyword,
            node.name,
            node.description,
            steps(language),
            examples_sections
          )
          scenario_outline.gherkin_statement(node)
          scenario_outline
        end

        def add_examples(examples_section, node)
          @examples_sections ||= []
          @examples_sections << [examples_section, node]
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

        private

        attr_reader :examples_sections
      end

      class StepBuilder < Spec
        def result(language)
          step = AST::Step.new(
            language,
            location,
            node.keyword,
            node.name,
            AST::MultilineArgument.from(node.doc_string || node.rows)
          )
          step.gherkin_statement(node)
          step
        end
      end

    end
  end
end
