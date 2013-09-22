require 'singleton'
require 'lucid/sequence/sequence_phrase'

module Sequence
  class SequenceGroup
    include Singleton
    
    def add_sequence(phrase, sequence, data)
      new_sequence = SequencePhrase.new(phrase, sequence, data)
      raise DuplicateSequenceError.new(phrase) if find_sequence(phrase, data)
      sequence_steps[new_sequence.key] = new_sequence
    end
    
    def sequence_steps
      @sequence_steps ||= {}
      return @sequence_steps
    end
    
    def generate_steps(phrase, data = nil)
      data_table =! data.nil?
      sequence = find_sequence(phrase, data_table)
      raise UnknownSequenceError.new(phrase) if sequence.nil?
      return sequence.expand(phrase, data)
    end
    
    def clear
      sequence_steps.clear
    end
    
    def find_sequence(phrase, data)
      key = SequencePhrase.sequence_key(phrase, data, :invoke)
      return sequence_steps[key]
    end
  end
end