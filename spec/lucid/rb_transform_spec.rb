require_relative '../spec_helper'

module Lucid
  module InterfaceRb
    describe RbTransform do

      def transform(regexp)
        RbTransform.new(nil, regexp, lambda { |a| })
      end
      
      it 'converts captures groups to non-capture groups' do
        transform(/(a|b)bc/).to_s.should == '(?:a|b)bc'
      end

      it 'leaves non-capture groups alone' do
        transform(/(?:a|b)bc/).to_s.should == '(?:a|b)bc'
      end

      it 'strips away line anchors' do
        transform(/^xyz$/).to_s.should == 'xyz'
      end
    end
  end
end