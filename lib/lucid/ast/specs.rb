module Lucid
  module AST
    class Specs
      include Enumerable

      def initialize
        @specs = []
      end

      def each(&proc)
        @specs.each(&proc)
      end

      def accept(visitor)
        puts "Running accept in specs"
        self.each do |feature|
          puts "The feature is #{feature}"
          visitor.visit_feature(feature)
        end
      end

    end
  end
end