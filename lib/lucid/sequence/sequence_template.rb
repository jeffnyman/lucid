require 'strscan'

module Sequence
  module SequenceTemplate
    
    class StaticText
      attr_reader :source
      
      def initialize(source)
        @source = source
      end
    end
    
    class EOLine
      
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
        if text =~ /^[\?\/]/
          matching = InvalidInternalElements.match(text[1..-1])
        else
          matching = InvalidInternalElements.match(text)
        end

        raise InvalidElementError.new(text, matching[0]) if matching
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
      end

      def generate_line(line)
        puts "generate.line: line = #{line}"
        line_rep = line.map { |item| generate_couple(item) }
        puts "generate.line: line_rep = #{line_rep}"

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
      
      def line_rep_ending(line)
        line << EOLine.new
      end
    end # class: Engine
    
  end
end