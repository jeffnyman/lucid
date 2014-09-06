require 'spec_helper'

describe Lucid::StepRunner do
  let(:mod) { Module.new }
  let(:obj) { Object.new.tap { |o| o.extend Lucid::StepRunner; o.extend mod } }

  it 'will indicate a step is pending if a matcher is not found' do
    test_step = Lucid::Builder::Step.new('* ', 'truth is truth', 27, [])
    expect {obj.step(test_step)}.to raise_error(Lucid::Pending)
  end
end
