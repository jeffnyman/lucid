require 'spec_helper'

describe Lucid::Builder do
  let(:builder) { Lucid::Builder.build(test_spec) }
  let(:feature) { builder.specs.first }

  context 'simple feature' do
    let(:test_spec) { File.expand_path('../../specs/structure.feature', File.dirname(__FILE__)) }

    it 'extracts the feature name' do
      expect(feature.name).to eq 'Provide Basic Parts of a Test Spec'
    end
  end
end
