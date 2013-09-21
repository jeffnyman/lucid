require_relative '../../spec_helper'

require_relative '../../../lib/lucid/sequence/sequence_group'

module Sequence
  describe SequenceGroup do

    let(:singleton) { SequenceGroup.instance() }

    context 'starting state' do
      it 'should be empty' do
        expect(singleton.sequence_steps).to be_empty
      end
    end
    
    context 'basic operation' do
      let(:example_steps) do
        example = <<-EXAMPLE
          Given the login page
          When  the username is "<username>"
          And   the password is "<password>"
          And   login is clicked
        EXAMPLE
      end

      it 'should accept the addition of a new sequence phrase' do
        phrase = '[enter credentials]'
        args = [phrase, example_steps, true]
        expect { singleton.add_sequence(*args) }.not_to raise_error
        expect(singleton).to have(1).sequence_steps
      end
      
      it 'should not accept the addition of an existing sequence phrase' do
        phrase = '[enter credentials]'
        args = [phrase, example_steps, true]
        msg = "A sequence with phrase '[enter credentials]' already exists."
        expect { singleton.add_sequence(*args) }.to raise_error(Sequence::DuplicateSequenceError, msg)
      end

      it 'should return the steps of a sequence phrase' do
        phrase = '[enter credentials]'
        input_values = [['username', 'jnyman'], ['password', 'thx1138']]
        generated = singleton.generate_steps(phrase, input_values)
        expected = <<-EXAMPLE
          Given the login page
          When  the username is "jnyman"
          And   the password is "thx1138"
          And   login is clicked
        EXAMPLE
        expect(generated).to eq(expected)
      end
    end
    
  end
end