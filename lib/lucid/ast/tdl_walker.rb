module Lucid
  module AST
    class TDLWalker

      def initialize(runtime, configuration)
        @runtime = runtime
        @configuration = configuration
      end

      # The ability to visit specs is the first step in turning a spec into
      # what is traditionally called a feature. The spec file and the feature
      # are initially the same concept. When the spec is visited, the high
      # level construct (feature, ability) is determined.
      def visit_specs(specs)

      end

    end
  end
end