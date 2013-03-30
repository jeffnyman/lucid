module Lucid
  class Runtime

    def initialize(configuration)
      @configuration = configuration
    end

    def run
      load_execution_context
    end

  private

    # Loading the execution context means getting all of the loadable files
    # in the spec repository. Loadable files means any code language type
    # files. These files are sent to an orchestrator instance that will be
    # responsible for loading them. The loading of these files provides the
    # execution context for Lucid as it runs executable specs.
    def load_execution_context
      #files = @configuration.support_to_load + @configuration.step_defs_to_load
      files = @configuration.library_context + @configuration.definition_context
      log.info("Runtime Load Execution Context: #{files}")
    end

    def log
      Lucid.logger
    end

  end
end