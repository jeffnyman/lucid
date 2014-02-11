module Lucid
  module AST
    class TDLWalker
      attr_accessor :configuration #:nodoc:
      attr_reader   :runtime #:nodoc:

      # @param listeners [Object] reference to formatter listeners
      def initialize(runtime, listeners = [], configuration = Lucid::Configuration.default)
        @runtime, @listeners, @configuration = runtime, listeners, configuration
      end

      # @param message [String] message being called
      # @param args [Array] instance of Lucid::AST::Spec
      def method_missing(message, *args, &block)
        send_message(message, *args, &block)
      end

      def visit_multiline_arg(multiline_arg) #:nodoc:
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
          listener.__send__(message, *args) if listener.respond_to?(message)
        end
      end
      def extract_method_name_from(call_stack)
        #call_stack[0].match(/in `(.*)'/).captures[0]
        match = call_stack.match(/in `(.*)'/)
        match.captures[0]
      end

    end
  end
end
