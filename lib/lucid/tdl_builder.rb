module Lucid
  module Parser
    # The TDL Builder conforms to the Gherkin event API.
    class TDLBuilder

      class Builder
        def initialize(node)
          @node = node
        end
      end

      class FeatureBuilder < Builder

      end

      def initialize(path)
        @path = path
      end

      def language=(language)
        @language = language
      end

      def eof
      end

      def uri(uri)
        @path = uri
      end

      def feature(node)
        @feature_builder = FeatureBuilder.new(node)
      end

      def scenario(node)

      end

      def step(node)

      end

    end
  end
end