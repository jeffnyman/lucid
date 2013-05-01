require 'gherkin/rubify'

module Lucid
  module AST
    module MultilineArgument

      class << self
        include Gherkin::Rubify

        def from(argument)
          return unless argument
          return argument if argument.respond_to?(:to_step_definition_arg)

          case(rubify(argument))
          when String
            # TODO: This duplicates work that Gherkin already does.
            # Ideally the string should be passed directly to Gherkin for parsing.
            AST::DocString.new(argument, '')
          when Gherkin::Formatter::Model::DocString
            AST::DocString.new(argument.value, argument.content_type)
          when Array
            AST::Table.new(argument.map{|row| row.cells})
          else
            raise ArgumentError, "Lucid does not know how to convert #{argument} into a multi-line argument."
          end
        end

      end
    end
  end
end
