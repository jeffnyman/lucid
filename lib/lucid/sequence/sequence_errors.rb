module Sequence
  
  class SequenceError < StandardError
  end
  
  class DuplicateSequenceError < SequenceError
    def initialize(phrase)
      super("A sequence with phrase '#{phrase}' already exists.")
    end
  end
  
end