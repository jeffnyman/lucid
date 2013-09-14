require 'singleton'
require 'lucid/sequence/sequence_step'

module Sequence
  class SequenceGroup
    include Singleton
    
    def add_sequence(phrase, sequence, data)
      new_sequence = SequenceStep.new(phrase, sequence, data)
      raise DuplicateSequenceError.new(phrase) if find_sequence(phrase, data)
      sequence_steps[new_sequence.key] = new_sequence
    end
    
    def sequence_steps
      @sequence_steps ||= {}
      return @sequence_steps
    end
    
    def find_sequence(phrase, data)
      key = SequenceStep.sequence_key(phrase, data, :invoke)
      return sequence_steps[key]
    end
  end
end