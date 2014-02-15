require 'fileutils'
require 'multi_json'
require 'gherkin/rubify'
require 'gherkin/i18n'
require 'lucid/context'
require 'lucid/load_path'
require 'lucid/interface'
require 'lucid/formatter/duration'
require 'lucid/interface_io'
require 'lucid/spec_loader'
require 'lucid/results'
require 'lucid/orchestrator'

module Lucid
  class ContextLoader
    attr_reader :results, :orchestrator

    include Formatter::Duration
    include ContextLoader::InterfaceIO

    def initialize(context = Context.default)
      @current_scenario = nil
      @context = Context.parse(context)
      @orchestrator = Orchestrator.new(self, @context)
      @results = Results.new(@context)
    end

    # Used to take an existing Lucid operation context and change the
    # configuration of that context.
    def configure(new_context)
      @context = Context.parse(new_context)
      @orchestrator.configure(@context)
      @results.configure(@context)
    end

    def load_code_language(language)
      @orchestrator.load_code_language(language)
    end

    def execute
      load_execution_context
      fire_after_configuration_hook

      ast_walker = @context.establish_ast_walker(self)
      self.visitor = ast_walker

      load_spec_context.accept(ast_walker)
    end

    def specs_paths
      @context.spec_source
    end

    def step_visited(step)
      @results.step_visited(step)
    end

    def scenarios(status = nil)
      @results.scenarios(status)
    end

    def steps(status = nil)
      @results.steps(status)
    end

    def step_match(step_name, name_to_report=nil)
      @orchestrator.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      @orchestrator.unmatched_step_definitions
    end

    def matcher_text(step_keyword, step_name, multiline_arg_class)
      @orchestrator.matcher_text(Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block)
      if skip_hooks
        yield
        return
      end

      @orchestrator.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false)
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      @results.scenario_visited(scenario)
    end

    def before(scenario)
      return if @context.dry_run? || @current_scenario
      @current_scenario = scenario
      @orchestrator.fire_hook(:before, scenario)
    end

    def after(scenario)
      @current_scenario = nil
      return if @context.dry_run?
      @orchestrator.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if @context.dry_run?
      @orchestrator.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @orchestrator.unknown_programming_language?
    end

    def write_testdefs_json
      if(@context.testdefs)
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
        if !File.directory?(@context.testdefs)
          FileUtils.mkdir_p(@context.testdefs)
        end
        File.open(File.join(@context.testdefs, 'testdefs.json'), 'w') do |io|
          io.write(MultiJson.dump(stepdefs, :pretty => true))
        end
      end
    end

    def doc_string(non_docstring, content_type='', line_offset=0)
      Lucid::AST::DocString.new(non_docstring, content_type)
    end

    private

    def fire_after_configuration_hook
      @orchestrator.fire_hook(:after_configuration, @context)
    end

    # The specs is used to begin loading the executable specs. This is as
    # opposed to loading the execution context (code files), which was
    # already handled. A SpecsLoader instance is created and this is what
    # makes sure that a spec file can be turned into a code construct
    # (a SpecFile instance) which in turn can be broken down into an AST.
    #
    # @return [Object] Instance of Lucid::AST::Spec
    def load_spec_context
      @loader ||= Lucid::ContextLoader::SpecLoader.new(
        @context.spec_context,
        @context.filters,
        @context.tag_expression)
      @loader.load_specs
    end

    # Determines what files should be included as part of the execution
    # context for Lucid as it runs executable specs. The "library" refers
    # to code that will be common to all specs while "definition" refers
    # to page/activity definitions as well as test definitions, which are
    # usually referred to as steps.
    def load_execution_context
      files = @context.library_context + @context.definition_context
      log.info("Load Execution Context: #{files}")
      @orchestrator.load_files(files)
    end

    def log
      Lucid.logger
    end
  end

end
