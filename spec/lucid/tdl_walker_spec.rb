require_relative '../spec_helper'

module Lucid::AST
  describe TDLWalker do
    let(:tdl_walker) do
      TDLWalker.new(nil, [double('listener', :before_visit_features => nil)])
    end
    let(:features) { double('features', :accept => nil) }

    it 'should visit features' do
      tdl_walker.should_not_receive(:warn)
      tdl_walker.visit_features(features)
    end

    it 'should return self' do
      tdl_walker.visit_features(features).should == tdl_walker
    end
  end
end