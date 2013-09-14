require 'strscan'

module Sequence
  module SequenceTemplate
    
    class Engine
      attr_reader :source
      
      def initialize(source)
        @source = source
        @generated_source = generate(source)
      end
      
      def self.parse(line)
        scanner = StringScanner.new(line)
        result = []
        
        until scanner.eos?
          tag_literal = scanner.scan(/<(?:[^\\<>]|\\.)*>/)
          puts "self.parse: tag_literal = #{tag_literal}"

          unless tag_literal.nil?
            result << [:dynamic, tag_literal.gsub(/^<|>$/, '')]
          end

          text_literal = scanner.scan(/(?:[^\\<>]|\\.)+/)
          puts "self.parse: text_literal = #{text_literal}"
          result << [:static, text_literal] unless text_literal.nil?
        end

        puts "self.parse: result = #{result}"
        
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
      end
    end
    
  end
end