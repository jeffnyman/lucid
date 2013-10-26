require_relative '../spec_helper'

module Lucid
  module InterfaceRb
    describe Matcher do
      
      before do
        @pattern = 'There is a missing step'
        @multiline_argument_class = nil
      end
      
      let(:code_keyword) { 'Given' }

      let(:matcher) do
        matcher_class.new(code_keyword, @pattern, @multiline_argument_class)
      end

      def unindent(s)
        s.split("\n")[1..-2].join("\n").indent(-10)
      end
      
      describe Matcher::Regexp do
        let(:matcher_class) { Matcher::Regexp }
        let(:matcher_text) { matcher.to_s }
        
        it 'should wrap matcher patterns in parentheses' do
          @pattern = 'A "string" with 4 spaces'

          matcher_text.should == unindent(%{
          Given (/^A "(.*?)" with (\\d+) spaces$/) do |arg1, arg2|
            pending
          end
          })
        end

        it 'should recognize numbers in name and make an according regexp' do
          @pattern = 'There are 4 spaces'

          matcher_text.should == unindent(%{
          Given (/^There are (\\d+) spaces$/) do |arg1|
            pending
          end
          })
        end

        it 'should recognise a mix of ints, strings and a table' do
          @pattern = 'There are 9 "lucid" tests in 20 "categories"'
          @multiline_argument_class = Lucid::AST::Table

          matcher_text.should == unindent(%{
          Given (/^There are (\\d+) "(.*?)" tests in (\\d+) "(.*?)"$/) do |arg1, arg2, arg3, arg4, table|
            # table is a Lucid::AST::Table
            pending
          end
          })
        end

        it "should recognize quotes in name and make according regexp" do
          @pattern = 'A "lucid" test'

          matcher_text.should == unindent(%{
          Given (/^A "(.*?)" test$/) do |arg1|
            pending
          end
          })
        end

        it 'should recognize several quoted words in name and make according regexp and args' do
          @pattern = 'A "first" and "second" arg'

          matcher_text.should == unindent(%{
          Given (/^A "(.*?)" and "(.*?)" arg$/) do |arg1, arg2|
            pending
          end
          })
        end

        it 'should not use quote group when there are no quotes' do
          @pattern = 'A first arg'

          matcher_text.should == unindent(%{
          Given (/^A first arg$/) do
            pending
          end
          })
        end

        it 'should be helpful with tables' do
          @pattern = 'A "first" arg'
          @multiline_argument_class = Lucid::AST::Table

          matcher_text.should == unindent(%{
          Given (/^A "(.*?)" arg$/) do |arg1, table|
            # table is a Lucid::AST::Table
            pending
          end
          })
        end
      end

      describe Matcher::Classic do
        let(:matcher_class) { Matcher::Classic }

        it 'renders matcher as unwrapped regular expression' do
          matcher.to_s.should eql unindent(%{
          Given /^There is a missing step$/ do
            pending
          end
          })
        end
      end
      
      describe Matcher::Percent do
        let(:matcher_class) { Matcher::Percent }

        it 'renders matcher as percent-style regular expression' do
          matcher.to_s.should eql unindent(%{
          Given %r{^There is a missing step$} do
            pending
          end
          })
        end
      end
      
    end
  end
end