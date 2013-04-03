module Lucid
  module Parser
    # The TDL Builder conforms to the Gherkin event API.
    class TDLBuilder

      def initialize(path)
        @path = path
      end

      def eof
      end

      def uri(uri)
        @path = uri
      end

      def feature(node)

      end

      def scenario(node)

      end

      def step(node)

      end

    end
  end
end