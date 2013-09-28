require 'lucid/sequence/sequence_group'
require 'lucid/sequence/sequence_errors'

module Sequence
  module SequenceSupport
    
    def add_sequence(phrase, sequence, data)
      SequenceGroup.instance.add_sequence(phrase, sequence, data)
    end
    
    def invoke_sequence(phrase, data = nil)
      # It's necessary to generate textual versions of all the steps that
      # are to be executed.
      group = SequenceGroup.instance
      generated_steps = group.generate_steps(phrase, data)
      
      # This statement causes Lucid to execute the generated test steps.
      steps(generated_steps)
    end
    
    def clear_sequences
      SequenceGroup.instance.clear
    end
    
  end
end