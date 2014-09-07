require 'spec_helper'

module Lucid::AST

  describe Walker do
    let(:tdl_walker) do
      Walker.new(nil, [double('listener', :before_visit_features => nil)])
    end
    let(:features) { double('features', :accept => nil) }

    it 'should visit features' do
      expect(tdl_walker).not_to receive(:warn)
      tdl_walker.visit_features(features)
    end

    it 'should return self' do
      expect(tdl_walker.visit_features(features)).to eq(tdl_walker)
    end
  end

end
