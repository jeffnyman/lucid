require_relative '../spec_helper'

module Lucid
  module InterfaceRb
    describe RegexpArgumentMatcher do

      it 'should create two arguments' do
        arguments = RegexpArgumentMatcher.arguments_from(/Lucid (\w+) (\w+)/, 'Lucid works well')
        arguments.map{|argument| [argument.val, argument.offset]}.should == [['works', 6], ['well', 12]]
      end

      it 'should create two arguments when first group is optional' do
        arguments = RegexpArgumentMatcher.arguments_from(/should( not)? be shown '([^']*?)'$/, "should be shown 'Login failed.'")
        arguments.map{|argument| [argument.val, argument.offset]}.should == [[nil, nil], ['Login failed.', 17]]
      end
      
    end
  end
end