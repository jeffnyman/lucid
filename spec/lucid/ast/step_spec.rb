require 'spec_helper'

require 'lucid/ast'
require 'lucid/lang_extend'

module Lucid
  module AST

    describe Step do
      let(:language) { double }

      it 'should replace arguments in name' do
        step = Step.new(language, 1, 'Given', 'a <status> test')

        invocation_table = Table.new([
            %w{status build},
            %w{passing failing}
                                     ])

        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)

        step_invocation.name.should == 'a passing test'
      end

      it 'should use empty string for the replacement of arguments in name when replace value is nil' do
        step = Step.new(language, 1, 'Given', 'a <status> test')

        invocation_table = Table.new([
            %w(status),
            [nil]
                                     ])

        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)

        step_invocation.name.should == 'a  test'
      end

      it 'should replace arguments in provided table arguments' do
        arg_table = Table.new([%w{status_<status> type_<type>}])
        step = Step.new(language, 1, 'Given', 'a <status> test', arg_table)

        invocation_table = Table.new([
            %w{status type},
            %w{passing regression}
                                     ])

        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)

        step_invocation.instance_variable_get('@multiline_arg').raw.should == [%w{status_passing type_regression}]
      end

      it 'should replace arguments in a doc string argument' do
        doc_string = DocString.new('status_<status> type_<type>', '')
        step = Step.new(language, 1, 'Given', 'a <status> test', doc_string)

        invocation_table = Table.new([
            %w{status type},
            %w{passing regression}
                                     ])

        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)

        step_invocation.instance_variable_get('@multiline_arg').to_step_definition_arg.should == 'status_passing type_regression'
      end

    end
  end
end
