require 'spec_helper'
require 'lucid/ast/doc_string'

module Lucid
  module AST
    describe DocString do

      describe 'replacing arguments' do
        before(:each) do
          @ps = DocString.new("<book>\n<qty>\n", '')
        end

        it 'should return a new doc_string with arguments replaced with values' do
          doc_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Leviathan', '<qty>' => '5'})
          expect(doc_string_with_replaced_arg.to_step_definition_arg).to eq("Leviathan\n5\n")
        end

        it 'should not change the original doc_string' do
          doc_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Leviathan'})
          expect(@ps.to_s).not_to include('Leviathan')
        end

        it 'should replace nil with empty string' do
          ps = DocString.new("'<book>'", '')
          doc_string_with_replaced_arg = ps.arguments_replaced({'<book>' => nil})
          expect(doc_string_with_replaced_arg.to_step_definition_arg).to eq("''")
        end

        it 'should recognise when just a subset of a cell is delimited' do
          #@ps.should have_text('<qty>')
          expect(@ps).to include('<qty>')
        end
      end

    end
  end
end
