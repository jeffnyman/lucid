module Lucid
  module AST
    class Spec
      include Enumerable

      attr_reader :duration

      def initialize
        @features = []
      end

      def [](index)
        @features[index]
      end

      def each(&proc)
        @features.each(&proc)
      end

      # @see Lucid::SpecLoader.load
      def add_feature(feature)
        @features << feature
      end

      # The ability to visit specs is the first step in turning a spec into
      # what is traditionally called a feature. The spec file and the feature
      # are initially the same concept. When the spec is visited, the high
      # level construct (feature, ability) is determined.
      def accept(visitor)
        visitor.visit_features(self) do
          start = Time.now

          self.each do |feature|
            log.ast(feature)
            feature.accept(visitor)
          end

          @duration = Time.now - start
        end
      end

      def step_count
        @features.inject(0) { |total, feature| total += feature.step_count }
      end

      private

      def log
        Lucid.logger
      end
    end
  end
end
