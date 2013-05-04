require 'gherkin/tag_expression'

module Lucid
  module AST
    class Tags #:nodoc:
      attr_reader :tags

      def initialize(line, tags)
        @line, @tags = line, tags
      end

      def accept(visitor)
        return if Lucid.wants_to_quit
        @tags.each do |tag|
          visitor.visit_tag_name(tag.name)
        end
      end

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).evaluate(@tags)
      end

      def to_sexp
        @tags.map{|tag| [:tag, tag.name]}
      end
    end
  end
end
