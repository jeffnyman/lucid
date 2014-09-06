module Lucid
  module StepRunner
    # @param step [Struct Lucid::Builder::Step] the step to execute
    # @see Lucid::RSpec::SpecRunner.run
    def step(step)
      step_matches = methods.map do |method|
        next unless method.to_s.start_with?('matcher: ')
      end.compact

      if step_matches.length == 0
        raise Lucid::Pending, step.name
      end
    end
  end
end
