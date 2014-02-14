require_relative '../spec_helper'
require 'lucid/formatter/progress'

module Lucid
  module Formatter
    describe Progress do

      before(:each) do
        Lucid::Term::ANSIColor.coloring = false
        @out = StringIO.new
        progress = Lucid::Formatter::Progress.new(double('Runtime'), @out, {})
        @visitor = Lucid::AST::Walker.new(nil, [progress])
      end

      describe 'visiting a table cell value without a status' do
        it 'should take the status from the last run step' do
          step_result = AST::StepResult.new('', '', nil, :failed, nil, 10, nil, nil)
          step_result.accept(@visitor)
          @visitor.visit_outline_table(double) do
            @visitor.visit_table_cell_value('value', nil)
          end
          @out.string.should == "FF"
        end
      end

      describe 'visiting a table cell which is a table header' do
        it 'should not output anything' do
          @visitor.visit_table_cell_value('value', :skipped_param)
          @out.string.should == ''
        end
      end
    end
  end
end
