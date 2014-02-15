module Lucid
  module AST
    class Walker
      attr_accessor :context
      attr_reader   :runtime

      def initialize(runtime, listeners = [], context = Lucid::Context.default)
        @runtime, @listeners, @context = runtime, listeners, context
      end

      # This is being used to forward on messages from the AST to
      # the formatters.
      def method_missing(message, *args, &block)
        send_message(message, *args, &block)
      end

      def visit_multiline_arg(multiline_arg)
        broadcast(multiline_arg) do
          multiline_arg.accept(self)
        end
      end

      private

      def broadcast(*args, &block)
        message = extract_method_name_from(caller[0])
        send_message message, *args, &block
        self
      end

      def send_message(message, *args, &block)
        return self if Lucid.wants_to_quit
        message = message.to_s.gsub('visit_', '')
        if block_given?
          send_to_listeners("before_#{message}", *args)
          yield if block_given?
          send_to_listeners("after_#{message}", *args)
        else
          send_to_listeners(message, *args)
        end
        self
      end

      def send_to_listeners(message, *args)
        @listeners.each do |listener|
          if listener.respond_to?(message)
            listener.__send__(message, *args)
          end
        end
      end

      def extract_method_name_from(call_stack)
        match = call_stack.match(/in `(.*)'/)
        match.captures[0]
      end

    end
  end
end
