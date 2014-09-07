require 'spec_helper'

require 'lucid/ast'
require 'lucid/lang_extend'
require 'lucid/interface_rb/rb_language'

module Lucid
  module AST

    describe ScenarioOutline do

      before do
        @runtime = Lucid::ContextLoader.new
        @runtime.load_code_language('rb')
        @dsl = Object.new
        @dsl.extend(Lucid::InterfaceRb::RbLucid)

        @dsl.Given(/^there are (\d+) tests$/) do |n|
          @initial = n.to_i
        end

        @dsl.When(/^testing (\d+) scenarios$/) do |n|
          @tested = n.to_i
        end

        @dsl.Then(/^there should be (\d+) tests$/) do |n|
          expect(@initial - @tested).to eq(n.to_i)
        end

        @dsl.Then(/^there should be (\d+) tests completed$/) do |n|
          expect(@tested).to eq(n.to_i)
        end

        location = AST::Location.new('test.spec', 19)
        language = double

        @scenario_outline = ScenarioOutline.new(
            language,
            location,
            background=AST::EmptyBackground.new,
            Comment.new(''),
            Tags.new(18, []),
            Tags.new(0, []),
            'Scenario:', 'Test Outline', '',
            [
                Step.new(language, location.on_line(20), 'Given', 'there are <start> tests'),
                Step.new(language, location.on_line(21), 'When',  'testing <tests> scenarios'),
                Step.new(language, location.on_line(22), 'Then',  'there should be <left> tests'),
                Step.new(language, location.on_line(23), 'And',   'there should be <tests> tests completed')
            ],
            [
                [
                    [
                        location.on_line(24),
                        Comment.new("# Testing\n"),
                        'Examples:',
                        'First table',
                        '',
                        [
                            %w{start tests left},
                            %w{12 5 7},
                            %w{20 6 14}
                        ]
                    ],
                    Gherkin::Formatter::Model::Examples.new(nil, nil, nil, nil, nil, nil, nil, nil)
                ]
            ]
        )
      end

      it 'should replace all variables and call outline once for each table row' do
        visitor = Walker.new(@runtime)
        #visitor.should_receive(:visit_table_row).exactly(3).times
        expect(visitor).to receive(:visit_table_row).exactly(3).times
        @scenario_outline.feature = double.as_null_object
        @scenario_outline.accept(visitor)
      end

    end

  end
end
