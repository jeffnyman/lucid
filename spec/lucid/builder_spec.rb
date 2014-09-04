require 'spec_helper'

describe Lucid::Builder do
  let(:builder) { Lucid::Builder.build(test_spec) }
  let(:feature) { builder.specs.first }

  context 'basic test spec file' do
    let(:test_spec) { File.expand_path('../../specs/structure.feature', File.dirname(__FILE__)) }
    let(:scenarios) { feature.scenarios }
    let(:steps) { feature.scenarios.first.steps }

    it 'has a feature name' do
      expect(feature.name).to eq 'Provide Basic Parts of a Test Spec'
    end

    it 'has a line for the feature' do
      expect(feature.line).to eq 5
    end

    it 'has a tag for the feature' do
      expect(feature.tags).to eq ['manual']
    end

    it 'has a scenario name' do
      expect(scenarios.first.name).to eq 'Truth is Truth'
    end

    it 'has a line for the scenario' do
      expect(scenarios.first.line).to eq 17
    end

    it 'has a tag for the scenario' do
      expect(scenarios.first.tags).to eq ['example']
    end

    it 'has a step name' do
      expect(steps.first.name).to eq 'true is almost certainly not false'
    end

    it 'has a step keyword' do
      expect(steps.first.keyword).to eq '* '
    end

    it 'has a line for the step' do
      expect(steps.first.line).to eq 27
    end
  end

  context 'representative test spec file' do
    let(:test_spec) { File.expand_path('../../specs/scenarios.spec', File.dirname(__FILE__)) }
    let(:scenarios) { feature.scenarios }
    let(:steps) { feature.scenarios.first.steps }

    it 'has a collection of steps' do
      expect(steps.map(&:name)).to eq([
        'looking up the definition of "CHUD"',
        'the result is "Contaminated Hazardous Urban Disposal"'
      ])
    end

    it 'has a collection of keywords' do
      expect(steps.map(&:keyword)).to eq(['When ', 'Then '])
    end

    it 'has a collection of lines' do
      expect(steps.map(&:line)).to eq([4, 5])
    end

    it 'has a collection of tags' do
      expect(scenarios.map(&:tags)).to eq([['manual', 'example']])
    end

    it 'has a full representation of all test steps' do
      expect(steps.map(&:to_s)).to eq([
        'When looking up the definition of "CHUD"',
        'Then the result is "Contaminated Hazardous Urban Disposal"'
      ])
    end
  end

  context 'test spec file with background' do
    let(:test_spec) { File.expand_path('../../specs/background.feature', File.dirname(__FILE__)) }
    let(:backgrounds) { feature.backgrounds }

    it 'has a background name' do
      expect(backgrounds.first.name).to eq ''
    end

    it 'has a background line' do
      expect(backgrounds.first.line).to eq 3
    end

    it 'has a background step' do
      expect(backgrounds.first.steps.map(&:name)).to eq(['the stardate page'])
    end

    it 'has a background step line' do
      expect(backgrounds.first.steps.map(&:line)).to eq([4])
    end
  end
end
