require 'lucid/ast/step_collection'

module Lucid
  module AST
    class EmptyBackground
      attr_writer :file
      attr_accessor :feature

      def failed?
        false
      end

      def feature_elements
        []
      end

      #def step_collection(step_invocations)
        #StepCollection.new(step_invocations)
      def create_step_invocations(step_invocations)
        StepInvocations.new(step_invocations)
      end

      def step_invocations
        []
      end

      def init
      end

      def accept(visitor)
      end
    end
  end
end

