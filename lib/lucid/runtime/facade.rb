require 'forwardable'

module Lucid
  class Runtime
    # This is what a programming language will consider to be a runtime.
    #
    # It's a thin class that directs the handul of methods needed by the
    # programming languages to the right place.
    class Facade
      extend Forwardable

      def initialize(orchestrator, interface)
        @orchestrator, @interface = orchestrator, interface
      end

      def_delegators :@interface,
        :embed,
        :ask,
        :puts,
        :features_paths,
        :step_match

      def_delegators :@orchestrator,
        :invoke_steps,
        :invoke,
        :load_code_language

      # Returns a Lucid::AST::Table for +text_or_table+, which can either
      # be a String:
      #
      #   table(%{
      #     | account | description | amount |
      #     | INT-100 | Taxi        | 114    |
      #     | CUC-101 | Peeler      | 22     |
      #   })
      #
      # or a 2D Array:
      #
      #   table([
      #     %w{ account description amount },
      #     %w{ INT-100 Taxi        114    },
      #     %w{ CUC-101 Peeler      22     }
      #   ])
      #
      def table(text_or_table, file=nil, line_offset=0)
        if Array === text_or_table
          AST::Table.new(text_or_table)
        else
          AST::Table.parse(text_or_table, file, line_offset)
        end
      end

      # Returns AST::DocString for +string_without_triple_quotes+.
      #
      def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
        AST::DocString.new(string_without_triple_quotes,content_type)
      end
    end
  end
end
