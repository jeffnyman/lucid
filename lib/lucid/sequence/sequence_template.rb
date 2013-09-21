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

        if actual_value.nil? && context.respond_to?(name.to_sym)
          actual_value = context.send(name.to_sym)
        end
        
        return actual_value
      end
    end
    
    class Placeholder < UnaryElement
      def output(context, params)
        actual_value = retrieve_value_from(context, params)
        
        result = case actual_value
                   when NilClass
                     ''
                   when Array
                     actual_value.join('<br/>')
                   when String
                     actual_value
                   else
                     actual_value.to_s()
                 end
        
        return result
      end
    end
    
    class EOLine
      def output(context, params)
        return "\n"
      end
    end

    class Section < UnaryElement
      attr_reader :children

      def initialize(name)
        super(name)
        @children = []
      end
      
      def add_child(child)
        children << child
      end
      
      def variables
        section_variables = children.each_with_object([]) do |child, result|
          case child
            when Placeholder
              result << child.name
            when Section
              result.concat(child.variables)
            else
              # noop
          end
        end
        return section_variables.flatten.uniq
      end
      
      def output(context, params)
        msg = "Method Section.#{__method__} must be implemented in subclass."
        raise NotImplementedError, msg
      end
    end
    
    SectionEndMarker = Struct.new(:name)
    
    class Engine
      attr_reader :source
      
      # Invalid internal elements refers to spaces, any punctuation sign or
      # delimiter that is forbidden between chevrons <...> template tags.
      InvalidInternalElements = begin
        forbidden = ' !"#' + "$%&'()*+,-./:;<=>?[\\]^`{|}~"
        all_escaped = []
        forbidden.each_char() { |ch| all_escaped << Regexp.escape(ch) }
        pattern = all_escaped.join('|')
        Regexp.new(pattern)
      end
      
      def initialize(source)
        @source = source
        
        # The generated source contains an internal representation of the
        # given template text.
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
          
          unless tag_literal.nil?
            result << [:dynamic, tag_literal.gsub(/^<|>$/, '')]
          end

          text_literal = scanner.scan(/(?:[^\\<>]|\\.)+/)
          result << [:static, text_literal] unless text_literal.nil?

          indicate_parsing_error(line) if tag_literal.nil? && text_literal.nil?
        end

        return result
      end

      def self.indicate_parsing_error(line)
        # The regular expression will be looking to match \< or \>. Those are
        # escaped chevrons and will be replaced.
        no_escaped = line.gsub(/\\[<>]/, '--')
        unbalance_count = 0

        no_escaped.each_char do |ch|
          case ch
            when '<'
              unbalance_count += 1
            when '>'
              unbalance_count -= 1
          end

          raise StandardError, "Nested opening chevron '<'." if unbalance_count > 1
          raise StandardError, "Missing opening chevron '<'." if unbalance_count < 0
        end

        raise StandardError, "Missing closing chevron '>'." if unbalance_count == 1
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
        
        result = case text[0, 1]
                   when '/'
                     SectionEndMarker.new(text[1..-1])
                   else
                     Placeholder.new(text)
                 end
        
        return result
      end
      
      # This method is used to retrieve all of the variable elements, which
      # will be placeholder names, that appear in the template.
      def variables
        @variables ||= begin
          vars = @generated_source.each_with_object([]) do |element, result|
            case element
              when Placeholder
                result << element.name
              when Section
                result.concat(element.variables)
              else
                # noop
            end
          end
          vars.flatten.uniq
        end
        return @variables
      end
      
      # This general output method will provide a final template within
      # the given scope object (Placeholder, StaticText, etc) and with
      # any of the parameters specified.
      def output(context, params)
        return '' if @generated_source.empty?
        result = @generated_source.each_with_object('') do |element, item|
          item << element.output(context, params)
        end
        return result
      end
      
      # To "generate" means to create an internal representation of
      # the template.
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
        line_rep = line.map { |item| generate_couple(item) }
        section_item = nil
        
        line_to_despace = line_rep.all? do |item|
          case item
            when StaticText
              item.source =~ /\s+/
            when Section, SectionEndMarker
              if section_item.nil?
                section_item = item
                true
              else
                false
              end
            else
              false
          end
        end

        if line_to_despace && ! section_item.nil?
          line_rep = [section_item]
        else
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
      
      def generate_sections(sequence)
        open_sections = []
        
        generated = sequence.each_with_object([]) do |element, result|
          case element
            when Section
              open_sections << element
            when SectionEndMarker
              validate_section_end(element, open_sections)
              result << open_sections.pop()
            else
              if open_sections.empty?
                result << element
              else
                open_sections.last.add_child(element)
              end
            end
          end

        unless open_sections.empty?
          error_message = "Unterminated section #{open_sections.last}."
          raise StandardError, error_message
        end
        
        return generated
      end

      def validate_section_end(marker, sections)
        if sections.empty?
          msg = "End of section </#{marker.name}> found while no corresponding section is open."
          raise StandardError, msg
        end

        if marker.name != sections.last.name
          msg = "End of section </#{marker.name}> does not match current section '#{sections.last.name}'."
          raise StandardError, msg
        end
      end
      
      def line_rep_ending(line)
        if line.last.is_a?(SectionEndMarker)
          section_end = line.pop()
          line << EOLine.new
          line << section_end
        else
          line << EOLine.new
        end
      end
      
    end # class: Engine
    
  end
end