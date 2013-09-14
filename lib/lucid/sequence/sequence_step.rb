require 'lucid/sequence/sequence_template'

module Sequence
  class SequenceStep
    
    attr_reader :key
    attr_reader :template
    attr_reader :phrase_params
    
    def initialize(phrase, sequence, data)
      @key = self.class.sequence_key(phrase, data, :define)
      puts "*** Sequence Step - Key: #{@key}"

      @phrase_params = scan_parameters(phrase, :define)
      puts "*** Sequence Step - Phrase Params: #{@phrase_params}"
      
      transformed_steps = preprocess(sequence)
      puts "*** Sequence Step - Steps: \n#{transformed_steps}"

      @template = SequenceTemplate::Engine.new(transformed_steps)
      puts "\n*** Sequence Step - Template: #{@template.inspect}\n"
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

    # "Scanning parameters" means that a phrase will be scanned to find any
    # text between chevrons or double quotes. These will be placed into an
    # array.
    def scan_parameters(phrase, mode)
      pattern = case mode
                  when :define
                    /<((?:[^\\<>]|\\.)*)>/
                  when :invoke
                    /"((?:[^\\"]|\\.)*)"/
                end

      result = phrase.scan(pattern)
      params = result.flatten.compact

      # Any escaped double quotes need to be replaced by a double quote.
      params.map! { |item| item.sub(/\\"/, '"') } if mode == :invoke
      
      return params
    end
    
    def preprocess(sequence)
      # Split text into individual lines and make sure to remove any lines
      # with hash style comments.
      lines = sequence.split(/\r\n?|\n/)
      processed = lines.reject { |line| line =~ /\s*#/ }

      return processed.join("\n")
    end
    
    def expand(phrase, data)
      
    end
    
  end
end