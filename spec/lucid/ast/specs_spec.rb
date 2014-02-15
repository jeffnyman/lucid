require 'spec_helper'

module Lucid
  module AST
    describe Spec do
      let(:specs) { Spec.new }

      def parse_feature(gherkin)
        path    = 'specs/test.spec'
        builder = Lucid::Parser::SpecBuilder.new(path)
        parser  = Gherkin::Parser::Parser.new(builder, true, 'root', false)
        parser.parse(gherkin, path, 0)
        builder.language = parser.i18n_language
        feature = builder.result
        specs.add_feature(feature)
      end

      it 'has a step_count' do
        parse_feature(<<-GHERKIN)
Feature:
  Background:
    Given step 1
    And step 2

  Scenario:
    Given step 3
    And step 4
    And step 5

  Scenario Outline:
    Given step <n>
    And another step

    Examples:
      | n |
      | 6 |
      | 7 |

    Examples:
      | n |
      | 8 |
        GHERKIN

        specs.step_count.should == (2 + 3) + (3 * (2 + 2))
      end
    end
  end
end
