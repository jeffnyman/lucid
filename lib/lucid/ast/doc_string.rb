module Lucid
  module AST
    class DocString < String #:nodoc:
      attr_accessor :file

      def self.default_arg_name
        "string"
      end

      attr_reader :content_type

      def initialize(string, content_type)
        @content_type = content_type
        super string
      end

      def to_step_definition_arg
        self
      end

      def accept(visitor)
        return if Lucid.wants_to_quit
        visitor.visit_doc_string(self)
      end

      def arguments_replaced(arguments) #:nodoc:
        string = self
        arguments.each do |name, value|
          value ||= ''
          string = string.gsub(name, value)
        end
        DocString.new(string, content_type)
      end

      def has_text?(text)
        index(text)
      end

      def to_sexp #:nodoc:
        [:doc_string, to_step_definition_arg]
      end
    end
  end
end
