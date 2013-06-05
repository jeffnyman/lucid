require 'fileutils'
require 'multi_json'
require 'gherkin/rubify'
require 'gherkin/i18n'
require 'lucid/configuration'
require 'lucid/load_path'
require 'lucid/interface_methods'
require 'lucid/formatter/duration'
require 'lucid/runtime/interface_io'
require 'lucid/runtime/specs_loader'
require 'lucid/runtime/results'
require 'lucid/runtime/orchestrator'

module Lucid
  class Runtime
    attr_reader :results

    include Formatter::Duration
    include Runtime::InterfaceIO

    def initialize(configuration = Configuration.default)
      if defined?(Test::Unit::Runner)
        Test::Unit::Runner.module_eval("@@stop_auto_run = true")
      end

      @current_scenario = nil
      @configuration = Configuration.parse(configuration)
      @orchestrator = Orchestrator.new(self, @configuration)
      @results = Results.new(@configuration)
    end

    # Used to take an existing runtime and change its configuration.
    def configure(new_configuration)
      @configuration = Configuration.parse(new_configuration)
      @orchestrator.configure(@configuration)
      @results.configure(@configuration)
    end

    def load_code_language(language)
      @orchestrator.load_code_language(language)
    end

    def run
      load_execution_context
      fire_after_configuration_hook

      tdl_walker = @configuration.establish_tdl_walker(self)
      self.visitor = tdl_walker

      specs.accept(tdl_walker)
    end

    def features_paths
      @configuration.spec_source
    end

    def step_visited(step) #:nodoc:
      @results.step_visited(step)
    end

    def scenarios(status = nil)
      @results.scenarios(status)
    end

    def steps(status = nil)
      @results.steps(status)
    end

    def step_match(step_name, name_to_report=nil) #:nodoc:
      @orchestrator.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      @orchestrator.unmatched_step_definitions
    end

    def matcher_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      @orchestrator.matcher_text(Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      if skip_hooks
        yield
        return
      end

      @orchestrator.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      @results.scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if @configuration.dry_run? || @current_scenario
      @current_scenario = scenario
      @orchestrator.fire_hook(:before, scenario)
    end

    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if @configuration.dry_run?
      @orchestrator.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if @configuration.dry_run?
      @orchestrator.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @orchestrator.unknown_programming_language?
    end

    def write_testdefs_json
      if(@configuration.testdefs)
        stepdefs = []
        @orchestrator.step_definitions.sort{|a,b| a.to_hash['source'] <=> a.to_hash['source']}.each do |stepdef|
          stepdef_hash = stepdef.to_hash
          steps = []
          specs.each do |feature|
            feature.feature_elements.each do |feature_element|
              feature_element.raw_steps.each do |step|
                args = stepdef.arguments_from(step.name)
                if(args)
                  steps << {
                    'name' => step.name,
                    'args' => args.map do |arg|
                      {
                        'offset' => arg.offset,
                        'val' => arg.val
                      }
                    end
                  }
                end
              end
            end
          end
          stepdef_hash['file_colon_line'] = stepdef.file_colon_line
          stepdef_hash['steps'] = steps.uniq.sort {|a,b| a['name'] <=> b['name']}
          stepdefs << stepdef_hash
        end
        if !File.directory?(@configuration.testdefs)
          FileUtils.mkdir_p(@configuration.testdefs)
        end
        File.open(File.join(@configuration.testdefs, 'testdefs.json'), 'w') do |io|
          io.write(MultiJson.dump(stepdefs, :pretty => true))
        end
      end
    end

    # Returns AST::DocString for +string_without_triple_quotes+.
    def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
      AST::DocString.new(string_without_triple_quotes,content_type)
    end

  private

    def fire_after_configuration_hook #:nodoc
      @orchestrator.fire_hook(:after_configuration, @configuration)
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
        @configuration.tag_expression)
      @loader.specs
    end

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

    def log
      Lucid.logger
    end
  end

end
