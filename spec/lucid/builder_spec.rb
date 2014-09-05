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

  context 'test spec file with table step argument' do
    let(:test_spec) { File.expand_path('../../specs/scenario_with_table.feature', File.dirname(__FILE__)) }
    let(:scenarios) { feature.scenarios }
    let(:steps) { feature.scenarios.first.steps }

    it 'has a step with a table' do
      table = steps[0].step_args.find { |a| a.instance_of?(Lucid::Table) }
      expect(table.hashes[0]['Planet']).to eq 'Mercury'
      expect(table.hashes[0]['Weight']).to eq '75.6'
    end
  end

  context 'test spec file with scenario outline' do
    let(:test_spec) { File.expand_path('../../specs/scenario_outline.story', File.dirname(__FILE__)) }

    it 'will apply the scenario outline name to each example' do
      expect(feature.scenarios.map(&:name)).to eq([
        'Convert Valid TNG Stardates',
        'Convert Valid TNG Stardates',
        'Convert Valid TNG Stardates'
      ])
    end

    it 'will replace placeholders in steps' do
      expect(feature.scenarios[0].steps.map(&:name)).to eq([
        'the stardate page',
        'the tng 46379.1 is converted',
        'the calendar year should be 2369'
      ])
      expect(feature.scenarios[1].steps.map(&:name)).to eq([
        'the stardate page',
        'the tng 48315.6 is converted',
        'the calendar year should be 2371'
      ])
    end
  end

  context 'test spec file with scenario outline and data table' do
    let(:test_spec) { File.expand_path('../../specs/scenario_outline_with_table.feature', File.dirname(__FILE__)) }

    it 'will replace placeholders in steps' do
      expect(feature.scenarios[0].steps.map(&:name)).to eq([
        'a hostile NPC with hitpoints and agility:',
        'the NPC suffers 120 points',
        'there is a 0 modifier applied',
        'the NPC should be wounded'
      ])
      table = feature.scenarios[0].steps[0].step_args.find { |arg| arg.instance_of? (Lucid::Table) }
      expect(table.hashes[0]['hit points']).to eq '100'
      expect(table.hashes[0]['agility']).to eq '10'

      table = feature.scenarios[1].steps[0].step_args.find { |arg| arg.instance_of? (Lucid::Table) }
      expect(table.hashes[0]['hit points']).to eq '100'
      expect(table.hashes[0]['agility']).to eq '0'
    end
  end
end
