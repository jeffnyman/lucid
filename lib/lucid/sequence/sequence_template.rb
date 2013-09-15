require 'strscan'

module Sequence
  module SequenceTemplate
    
    class StaticText
      attr_reader :source
      
      def initialize(source)
        @source = source
      end
      
      def output(context, params)
        return source
      end
    end
    
    class UnaryElement
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
      
      def retrieve_value_from(context, params)
        actual_value = params[name]
        
        return actual_value
      end
    end
    
    class Placeholder < UnaryElement
      def output(context, params)
        actual_value = retrieve_value_from(context, params)
        
        #puts "&&&&&&&&& Actual Value: #{actual_value} (#{actual_value.inspect})"
        
        result = case actual_value
                   when String
                     actual_value
                 end
        
        return result
      end
    end
    
    class EOLine
      def output(context, params)
        return "\n"
      end
    end
    
    class Engine
      attr_reader :source

      InvalidInternalElements = begin
        forbidden = ' !"#' + "$%&'()*+,-./:;<=>?[\\]^`{|}~"
        all_escaped = []
        forbidden.each_char() { |ch| all_escaped << Regexp.escape(ch) }
        pattern = all_escaped.join('|')
        Regexp.new(pattern)
      end
      
      def initialize(source)
        @source = source
        @generated_source = generate(source)
      end
      
      # The parse mechanism is designed to break up TDL lines into static
      # and dynamic components. Dynamic components will correspond to
      # tagged elements of the string, which indicate parameters in the
      # original TDL phrase.
      def self.parse(line)
        scanner = StringScanner.new(line)
        result = []
        
        until scanner.eos?
          tag_literal = scanner.scan(/<(?:[^\\<>]|\\.)*>/)
          #puts "self.parse: tag_literal = #{tag_literal}"

          unless tag_literal.nil?
            result << [:dynamic, tag_literal.gsub(/^<|>$/, '')]
          end

          text_literal = scanner.scan(/(?:[^\\<>]|\\.)+/)
          #puts "self.parse: text_literal = #{text_literal}"
          result << [:static, text_literal] unless text_literal.nil?
        end

        #puts "self.parse: result = #{result}"
        
        return result
      end
      
      def parse_element(text)
        # Check if the text matched is a ? or a / character. If the next bit
        # of text after the ? or / is a invalid element of if there is an
        # invalid element at all, an error will be raised.
        #puts "&&&&&&&&&&&&&&&& text = #{text}"
        if text =~ /^[\?\/]/
          matching = InvalidInternalElements.match(text[1..-1])
        else
          matching = InvalidInternalElements.match(text)
        end

        raise InvalidElementError.new(text, matching[0]) if matching
        
        result = case text[0, 1]
                   when '/'
                     #
                   else
                     Placeholder.new(text)
                 end
        
        return result
      end
      
      def variables
        @variables ||= begin
          vars = @generated_source.each_with_object([]) do |element, result|
            case element
              when Placeholder
                result << element.name
              else
                # noop
            end
          end
          vars.flatten.uniq
        end
        return @variables
      end
      
      def output(context, params)
        return '' if @generated_source.empty?
        result = @generated_source.each_with_object('') do |element, item|
          item << element.output(context, params)
        end
        return result
      end
      
      def generate(source)
        input_lines = source.split(/\r\n?|\n/)

        raw_lines = input_lines.map do |line|
          line_items = self.class.parse(line)
          line_items.each do |(kind, text)|
            if (kind == :dynamic) && text.strip.empty?
              raise EmptyParameterError.new(line.strip)
            end
          end
          line_items
        end

        template_lines = raw_lines.map { |line| generate_line(line) }
        return generate_sections(template_lines.flatten)
      end

      def generate_line(line)
        #puts "generate.line: line = #{line}"
        line_rep = line.map { |item| generate_couple(item) }
        #puts "generate.line: line_rep = #{line_rep}"

        line_to_despace = line_rep.all? do |item|
          case item
            when StaticText
              item.source =~ /\s+/
            else
              false
          end
        end

        if line_to_despace
          line_rep_ending(line_rep)
        end
        
        #puts "generate.line: final_line_rep = #{line_rep}"
        
        return line_rep
      end
      
      def generate_couple(item)
        (kind, text) = item
        
        result = case kind
                   when :static
                     StaticText.new(text)
                   when :dynamic
                     parse_element(text)
                 end
        
        return result
      end
      
      def generate_sections(sequence)
        generated = sequence.each_with_object([]) do |element, result|
          result << element
        end
        
        return generated
      end
      
      def line_rep_ending(line)
        line << EOLine.new
      end
    end # class: Engine
    
  end
end