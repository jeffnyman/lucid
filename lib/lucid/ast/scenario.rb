require 'lucid/ast/has_steps'
require 'lucid/ast/names'
require 'lucid/ast/empty_background'
require 'lucid/ast/location'
require 'lucid/unit'

module Lucid
  module AST
    class Scenario #:nodoc:
      include HasSteps
      include Names
      include HasLocation

      attr_reader   :feature_tags
      attr_accessor :feature
      attr_reader   :comment, :tags, :keyword, :background

      def initialize(language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps)
        @language, @location, @background, @comment, @tags, @feature_tags, @keyword, @title, @description, @raw_steps = language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps
        @exception = @executed = nil
        attach_steps(@raw_steps)
      end

      def accept(visitor)
        visitor.visit_feature_element(self) do
          comment.accept(visitor)
          tags.accept(visitor)
          visitor.visit_scenario_name(keyword, name, file_colon_line, source_indent(first_line_length))

          skip_invoke! if background.failed?
          with_visitor(visitor) do
            execute(visitor.runtime, visitor)
          end

          @executed = true
        end
      end

      def execute(runtime, visitor)
        runtime.with_hooks(self, skip_hooks?) do
          step_invocations.accept(visitor)
        end
      end

      def to_units(background)
        #[Unit.new(background.step_invocations + step_invocations)]
        [Unit.new(step_invocations)]
      end

      # Returns true if one or more steps failed.
      def failed?
        #steps.failed? || !!@exception
        step_invocations.failed? || !!@exception
      end

      def fail!(exception)
        @exception = exception
        @current_visitor.visit_exception(@exception, :failed)
        skip_invoke!
      end

      # Returns true if all steps passed.
      def passed?
        !failed?
      end

      # Returns the first exception (if any).
      def exception
        #@exception || steps.exception
        @exception || step_invocations.exception
      end

      # Returns the status.
      def status
        return :failed if @exception
        #steps.status
        step_invocations.status
      end

      def to_sexp
        sexp = [:scenario, line, @keyword, name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        #sexp += steps.to_sexp if steps.any?
        sexp += step_invocations.to_sexp if step_invocations.any?
        sexp
      end

      def with_visitor(visitor)
        @current_visitor = visitor
        yield
        @current_visitor = nil
      end

      def skip_invoke!
        #steps.skip_invoke!
        step_invocations.skip_invoke!
      end

      #def steps
        #@steps ||= @background.step_collection(step_invocations)
      def step_invocations
        @step_invocation ||= @background.create_step_invocations(my_step_invocations)
      end

      private

      #def step_invocations
        #@raw_steps.map{|step| step.step_invocation}
      def steps
        StepCollection.new(@raw_steps)
      end

      def my_step_invocations
        @raw_steps.map { |step| step.step_invocation }
      end

      def skip_hooks?
        @background.failed? || @executed
      end

    end
  end
end
