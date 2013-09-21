require 'lucid/sequence/sequence_template'
require 'lucid/sequence/sequence_errors'

module Sequence
  class SequencePhrase
    
    attr_reader :key
    attr_reader :values
    attr_reader :template
    attr_reader :phrase_params

    ParameterConstant = { 'quotes' => '""'}
    
    def initialize(phrase, sequence, data)
      @key = self.class.sequence_key(phrase, data, :define)
      #puts "*** [Sequence Step] - Key: #{@key}"

      @phrase_params = scan_parameters(phrase, :define)
      #puts "*** [Sequence Step] - Phrase Params: #{@phrase_params}"
      
      transformed_steps = preprocess(sequence)
      #puts "*** [Sequence Step] - Steps: \n#{transformed_steps}"

      @template = SequenceTemplate::Engine.new(transformed_steps)
      #puts "\n*** [Sequence Step] - Template: #{@template.inspect}\n"

      phrase_variables = template.variables
      #puts "\n*** [Sequence Step] - Phrase Variables: #{phrase_variables}"
      
      @values = validate_phrase_values(@phrase_params, phrase_variables)
      @values.concat(phrase_variables)
      #puts "*** [Sequence Step] - Values: #{@values}"
      
      @values.uniq!
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

      # Here 'patterned' means that for a given phrase, any bit of text
      # between quotes or chevrons is replaced by the letter X.
      patterned = new_phrase.gsub(pattern, 'X')

      key = patterned + (data ? '_T' : '')
      
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

      
      # If the sequence phrase is:
      # Given the step "When [checking a triangle with <side1>, <side2>, <side3> as sides]" is defined to mean:
      # The result will be: [["side1"], ["side2"], ["side3"]]
      # The params will be: ["side1", "side2", "side3"]
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
    
    def validate_phrase_values(params, phrase_variables)
      params.each do |param|
        unless phrase_variables.include? param
          raise UselessPhraseParameter.new(param)
        end
      end

      unless data_table_required?
        phrase_variables.each do |variable|
          unless params.include?(variable) || ParameterConstant.include?(variable)
            raise UnreachableStepParameter.new(variable)
          end
        end  
      end
            
      return phrase_params.dup
    end

    def data_table_required?
      return key =~ /_T$/
    end
    
    def expand(phrase, data)
      params = validate_params(phrase, data)
      params = ParameterConstant.merge(params)
      return template.output(nil, params)
    end
    
    def validate_params(phrase, data)
      sequence_parameters = {}
      
      quoted_values = scan_parameters(phrase, :invoke)
      quoted_values.each_with_index do |val, index|
        sequence_parameters[phrase_params[index]] = val
      end

      unless data.nil?
        data.each do |row|
          (key, value) = validate_row(row, sequence_parameters)
          if sequence_parameters.include? key
            if sequence_parameters[key].kind_of?(Array)
              sequence_parameters[key] << value
            else
              sequence_parameters[key] = [sequence_parameters[key], value]
            end
          else
            sequence_parameters[key] = value
          end
        end
      end

      return sequence_parameters
    end
    
    def validate_row(row, params)
      (key, value) = row

      raise UnknownParameterError.new(key) unless values.include? key

      if (phrase_params.include? key) && (params[key] != value)
        raise AmbiguousParameterValue.new(key, params[key], value)
      end

      return row
    end
    
  end
end