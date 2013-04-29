module Lucid
  class StepDefinitions
    def initialize(configuration = Configuration.default)
      configuration = Configuration.parse(configuration)
      @orchestrator = Runtime::Orchestrator.new(nil, false)
      @orchestrator.load_files_from_paths(configuration.autoload_code_paths)
    end

    def to_json
      @orchestrator.step_definitions.map{|stepdef| stepdef.to_hash}.to_json
    end
  end
end
