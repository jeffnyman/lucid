module Sequence
  class SequenceStep
    
    attr_reader :key
    
    def initialize(phrase, sequence, data)
      @key = self.class.sequence_key(phrase, data, :define)
      puts "*** Sequence Step - Key: #{@key}"
      
    end
    
    def self.sequence_key(phrase, data, mode)
      new_phrase = phrase.strip

      # These lines replace every series of whitespace with an underscore.
      # For that to work, I have to make sure there are no existing
      # underscore characters in the first place so any pre-existing
      # underscores get removed first.
      new_phrase.gsub!(/_/, '')
      new_phrase.gsub!(/\s+/, '_')

      pattern = case mode
                  when :define
                    /<(?:[^\\<>]|\\.)*>/
                  when :invoke
                    /"([^\\"]|\\.)*"/
                end

      # Here 'normalized' means that for a given phrase, any bit of text
      # between quotes or chevrons is replaced by the letter X.
      normalized = new_phrase.gsub(pattern, 'X')

      key = normalized + (data ? '_T' : '')
      
      return key
    end
    
  end
end