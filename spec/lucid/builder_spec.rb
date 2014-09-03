require 'spec_helper'

describe Lucid::Builder do
  let(:builder) { Lucid::Builder.build(test_spec) }
  let(:feature) { builder.specs.first }

  context 'basic test spec file' do
    let(:test_spec) { File.expand_path('../../specs/structure.feature', File.dirname(__FILE__)) }
    let(:scenarios) { feature.scenarios }

    it 'has a feature name' do
      expect(feature.name).to eq 'Provide Basic Parts of a Test Spec'
    end

    it 'has a scenario name' do
      expect(scenarios.first.name).to eq 'Truth is Truth'
    end
  end
end
