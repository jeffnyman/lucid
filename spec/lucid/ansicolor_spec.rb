require_relative '../spec_helper'

module Lucid
  module Formatter
    describe ANSIColor do
      include ANSIColor
      
      it 'should wrap passed_param with bold green and reset to green' do
        passed_param('test').should == "\e[32m\e[1mtest\e[0m\e[0m\e[32m"
      end

      it 'should wrap passed in green' do
        passed('test').should == "\e[32mtest\e[0m"
      end

      it 'should not reset passed if there are no arguments' do
        passed.should == "\e[32m"
      end

      it 'should wrap comments in grey' do
        comment('test').should == "\e[90mtest\e[0m"
      end

      it 'should not generate ansi codes when colors are disabled' do
        ::Lucid::Term::ANSIColor.coloring = false
        passed('test').should == 'test'
      end
      
    end
  end
end