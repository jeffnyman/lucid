require 'lucid/ast'

module Lucid
  module AST
    module TDLFactory

      class TestDomain

      end

      def create_feature(dsl)
        dsl.Given (/^a (.*) step with an inline argument:$/) do |action, table|
        end

        dsl.Given (/^a (.*) step$/) do |action|
        end

        dsl.Domain do
          TestDomain.new
        end

        table = AST::Table.new([
                                   %w{1 22 333},
                                   %w{4444 55555 666666}
                               ])

        doc_string = AST::DocString.new(%{\n Testing with\nLucid tools\n}, '')
        location = AST::Location.new('test.spec', 2)
        language = double.as_null_object

        background = AST::Background.new(
            language,
            location,
            AST::Comment.new(''),
            'Background:',
            '',
            '',
            [
                Step.new(language, location.on_line(3), 'Given', 'a passing step')
            ]
        )

        if Lucid::WINDOWS
          location = Location.new('specs\\test.spec', 0)
        else
          location = Location.new('specs/test.spec', 0)
        end

        AST::Feature.new(
            location,
            background,
            AST::Comment.new("# Feature Comment Line\n"),
            AST::Tags.new(6, [Gherkin::Formatter::Model::Tag.new('smoke', 6),
                              Gherkin::Formatter::Model::Tag.new('critical', 6)]),
            'Feature',
            'Testing TDL',
            '',
            [AST::Scenario.new(
                 language,
                 location.on_line(9),
                 background,
                 AST::Comment.new("   # Scenario Comment Line 1 \n# Scenario Comment Line 2 \n"),
                 AST::Tags.new(8, [Gherkin::Formatter::Model::Tag.new('regression', 8),
                                   Gherkin::Formatter::Model::Tag.new('selenium', 8)]),
                 AST::Tags.new(1, []),
                 'Scenario:', 'Test Scenario', '',
                 [
                     Step.new(language, location.on_line(10), 'Given', 'a passing step with an inline argument:', table),
                     Step.new(language, location.on_line(11), 'Given', 'a working step with an inline argument:', doc_string),
                     Step.new(language, location.on_line(12), 'Given', 'a non-passing step')
                 ]
             )]
        )
      end
      
    end
  end
end