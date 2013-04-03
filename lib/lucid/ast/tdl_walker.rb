module Lucid
  module AST
    class TDLWalker

      def initialize(runtime, listeners = [], configuration)
        @runtime = runtime
        @listeners = listeners
        @configuration = configuration
      end

      # The ability to visit specs is the first step in turning a spec into
      # what is traditionally called a feature. The spec file and the feature
      # are initially the same concept. When the spec is visited, the high
      # level construct (feature, ability) is determined.
      def visit_specs(specs)
        broadcast(specs) do
          specs.accept(self)
        end
      end

    private

      def broadcast(*args, &block)
        message = extract_method(caller)
        message.gsub!('visit_', '')
        if block_given?
          send_to_all("before_#{message}", *args)
          yield if block_given?
          send_to_all("after_#{message}", *args)
        else
          send_to_all(message, *args)
        end
        self
      end

      def extract_method(call_stack)
        call_stack[0].match(/in `(.*)'/).captures[0]
      end

      def send_to_all(message, *args)
        @listeners.each do |listener|
          if listener.respond_to?(message)
            listener.__send__(message, *args)
          end
        end
      end

    end
  end
end