require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_support'

module Sequence
  
  class TestDomain
    include Sequence::SequenceSupport
    
    attr_reader :seq_steps
    
    def steps(generated_steps)
      @seq_steps ||= {}
      @seq_steps << generated_steps
    end
  end
  
  describe SequenceSupport do
    let(:domain) { TestDomain.new }
    let(:phrase) { 'enter credentials' }

    let(:example_steps) do
      example = <<-EXAMPLE
          Given the login page
          When  the username is "<username>"
          And   the password is "<password>"
          And   login is clicked
      EXAMPLE
    end
    
    context 'defining a sequence' do
      it 'should add a valid new sequence phrase and associated steps' do
        expect { domain.add_sequence phrase, example_steps, true }.not_to raise_error
      end

      it 'should not add an existing sequence phrase' do
        msg = "A sequence with phrase 'enter credentials' already exists."
        expect { domain.add_sequence(phrase, example_steps, true) }.to raise_error(Sequence::DuplicateSequenceError, msg)
      end

      it 'should not allow a sequence to have steps with arguments and no way to use those arguments' do
        phrase = 'fill in the credentials'
        msg = "The step parameter 'username' does not appear in the phrase."
        expect { domain.add_sequence(phrase, example_steps, false) }.to raise_error(Sequence::UnreachableStepParameter, msg)
      end
    end
    
    context 'invoking a sequence' do
      it 'should not be able to invoke an unknown sequence phrase' do
        phrase = 'fill in the credentials'
        msg = "Unknown sequence step with phrase: 'fill in the credentials'."
        expect { domain.invoke_sequence(phrase) }.to raise_error(Sequence::UnknownSequenceError, msg)
      end
    end
    
    context 'clearing sequences' do
      it 'should clear all sequences from the sequence group' do
        expect { domain.clear_sequences() }.not_to raise_error
        expect(SequenceGroup.instance.sequence_steps).to be_empty
      end
            
    end
    
  end
  
end