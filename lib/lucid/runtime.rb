require "lucid/ast"
require "lucid/spec_file"
require "lucid/runtime/orchestrator"
require "lucid/runtime/specs_loader"

module Lucid
  class Runtime

    def initialize(configuration)
      @configuration = configuration
      @orchestrator = Orchestrator.new(self, @configuration)
    end

    def run
      load_execution_context

      tdl_walker = @configuration.establish_tdl_walker(self)
      tdl_walker.visit_specs(specs)
    end

  private

    # Loading the execution context means getting all of the loadable files
    # in the spec repository. Loadable files means any code language type
    # files. These files are sent to an orchestrator instance that will be
    # responsible for loading them. The loading of these files provides the
    # execution context for Lucid as it runs executable specs.
    def load_execution_context
      files = @configuration.library_context + @configuration.definition_context
      log.info("Runtime Load Execution Context: #{files}")
      @orchestrator.load_files(files)
    end

    # The specs is used to begin loading the executable specs. This is as
    # opposed to loading the execution context (code files), which was
    # already handled. A SpecsLoader instance is created and this is what
    # makes sure that a spec file can be turned into a code construct
    # (a SpecFile instance) which in turn can be broken down into an AST.
    def specs
      @loader ||= Runtime::SpecsLoader.new(
          @configuration.spec_files,
          @configuration.filters,
          @configuration.tags
      )
      @loader.specs
    end

    def log
      Lucid.logger
    end

  end
end