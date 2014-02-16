require 'forwardable'

module Lucid
  class ContextLoader
    # This is what a programming language will consider to be a runtime.
    #
    # It's a thin class that directs the specific methods needed by the
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
        :specs_paths,
        :step_match

      def_delegators :@orchestrator,
        :invoke_steps,
        :invoke,
        :load_code_language

      # Returns a Lucid::AST::Table which can either be a String:
      #
      #   table(%{
      #     | study   | phase  |
      #     | Test-01 | I      |
      #     | Test-02 | II     |
      #   })
      #
      # or a 2D Array:
      #
      #   table([
      #     %w{ study phase },
      #     %w{ Test-01 I },
      #     %w{ Test-02 II }
      #   ])
      #
      def table(text_or_table, file=nil, line_offset=0)
        if Array === text_or_table
          Lucid::AST::Table.new(text_or_table)
        else
          Lucid::AST::Table.parse(text_or_table, file, line_offset)
        end
      end

      def doc_string(non_docstring, content_type='', line_offset=0)
        Lucid::AST::DocString.new(non_docstring, content_type)
      end
    end
  end
end
