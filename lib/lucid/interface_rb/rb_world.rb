require 'gherkin/formatter/ansi_escapes'

module Lucid
  module InterfaceRb
    # Defines the basic DSL methods available in all Lucid test definitions.
    #
    # You can, and probably should, extend this DSL with your own methods that
    # make sense in your own domain.
    # @see Lucid::InterfaceRb::RbLucid#Domain
    module RbDomain

      AnsiEscapes = Gherkin::Formatter::AnsiEscapes

      # Call a Transform with a string from another Transform definition
      def Transform(arg)
        rb = @__lucid_runtime.load_code_language('rb')
        rb.execute_transforms([arg]).first
      end

      # @private
      attr_writer :__lucid_runtime, :__natural_language

      # Run a single Gherkin step
      # @example Call another step
      #   step "I am logged in"
      # @example Call a step with quotes in the name
      #   step %{the user "Jeff" is logged in}
      # @example Passing a table
      #   step "the following users exist:", table(%{
      #     | name   | email           |
      #     | Jeff   | jeff@jeff.com   |
      #     | Harley | harley@jeff.com |
      #   })
      # @example Passing a multiline string
      #   step "the email should contain:", "Dear sir,\nYou've won a prize!\n"
      # @param [String] name The name of the step
      # @param [String,Lucid::AST::DocString,Lucid::AST::Table] multiline_argument
      def step(name, multiline_argument=nil)
        @__lucid_runtime.invoke(name, multiline_argument)
      end

      # Run a matcher of Gherkin
      # @example
      #   steps %{
      #     Given the user "Jeff" exists
      #     And I am logged in as "Jeff"
      #   }
      # @param [String] steps_text The Gherkin matcher to run
      def steps(steps_text)
        @__lucid_runtime.invoke_steps(steps_text, @__natural_language, caller[0])
      end

      # Parse Gherkin into a {Lucid::AST::Table} object.
      #
      # Useful in conjunction with the #step method.
      # @example Create a table
      #   users = table(%{
      #     | name   | email           |
      #     | Jeff   | jeff@jeff.com   |
      #     | Harley | harley@jeff.com |
      #   })
      # @param [String] text_or_table The Gherkin string that represents the table
      def table(text_or_table, file=nil, line_offset=0)
        @__lucid_runtime.table(text_or_table, file, line_offset)
      end

      # Create an {Lucid::AST::DocString} object
      #
      # Useful in conjunction with the #step method, when
      # want to specify a content type.
      # @example Create a multiline string
      #   code = multiline_string(%{
      #     puts "this is ruby code"
      #   %}, 'ruby')
      def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
        # TODO: rename this method to multiline_string
        @__lucid_runtime.doc_string(string_without_triple_quotes, content_type, line_offset)
      end

      # @deprecated Use {#puts} instead.
      def announce(*messages)
        STDERR.puts AnsiEscapes.failed + "WARNING: #announce is deprecated. Use #puts instead:" + caller[0] + AnsiEscapes.reset
        puts(*messages)
      end

      # Print a message to the output.
      #
      # @note Lucid might surprise you with the behavior of this method. Instead
      #   of sending the output directly to STDOUT, Lucid will intercept and cache
      #   the message until the current step has finished, and then display it.
      #   
      #   If you'd prefer to see the message immediately, call {Kernel.puts} instead.
      def puts(*messages)
        @__lucid_runtime.puts(*messages)
      end

      # Pause the tests and ask the operator for input
      def ask(question, timeout_seconds=60)
        @__lucid_runtime.ask(question, timeout_seconds)
      end

      # Embed an image in the output
      def embed(file, mime_type, label='Screenshot')
        @__lucid_runtime.embed(file, mime_type, label)
      end

      # Mark the matched step as pending.
      def pending(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception
            raise Pending.new(message)
          end
          raise Pending.new("Expected pending '#{message}' to fail. No Error was raised. No longer pending?")
        else
          raise Pending.new(message)
        end
      end

      # Prints the list of modules that are included in the Domain
      def inspect
        modules = [self.class]
        (class << self; self; end).instance_eval do
          modules += included_modules
        end
        sprintf("#<%s:0x%x>", modules.join('+'), self.object_id)
      end

      # see {#inspect}
      def to_s
        inspect
      end
    end
  end
end
