module Lucid
  module AST
    class Specs #:nodoc:
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

      def add_feature(feature)
        @features << feature
      end

      def accept(visitor)
        return if Lucid.wants_to_quit
        start = Time.now
        self.each do |feature|
          feature.accept(visitor)
        end
        @duration = Time.now - start
      end

      def step_count
        @features.inject(0) { |total, feature| total += feature.step_count }
      end
    end
  end
end
