module Lucid
  class StepDefinitions
    def initialize(context = Context.default)
      context = Context.parse(context)
      @orchestrator = ContextLoader::Orchestrator.new(nil, false)
      @orchestrator.load_files_from_paths(context.autoload_code_paths)
    end

    def to_json
      @orchestrator.step_definitions.map{|stepdef| stepdef.to_hash}.to_json
    end
  end
end
