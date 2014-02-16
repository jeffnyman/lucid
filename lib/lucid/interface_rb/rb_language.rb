require 'lucid/lang_extend'
require 'lucid/interface_rb/rb_lucid'
require 'lucid/interface_rb/rb_world'
require 'lucid/interface_rb/rb_step_definition'
require 'lucid/interface_rb/rb_hook'
require 'lucid/interface_rb/rb_transform'
require 'lucid/interface_rb/matcher'

begin
  require 'rspec/expectations'
rescue LoadError
  require 'test/unit/assertions'
end

module Lucid
  module InterfaceRb
    class NilDomain < StandardError
      def initialize
        super('Domain procs should never return nil.')
      end
    end

    class MultipleDomain < StandardError
      def initialize(first_proc, second_proc)
        message = "You can only pass a proc to #Domain once, but it's happening\n"
        message << "in two places:\n\n"
        message << first_proc.backtrace_line('Domain') << "\n"
        message << second_proc.backtrace_line('Domain') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds.\n"
        super(message)
      end
    end

    class RbLanguage
      include Interface::InterfaceMethods
      attr_reader :current_domain, :step_definitions

      Gherkin::I18n.code_keywords.each do |adverb|
        RbLucid.alias_adverb(adverb)
      end

      def initialize(runtime)
        @runtime = runtime
        @step_definitions = []
        RbLucid.rb_language = self
        @domain_proc = @domain_modules = nil
        @assertions_module = find_best_assertions_module
      end

      def find_best_assertions_module
        begin
          ::RSpec::Matchers
        rescue NameError
          ::Test::Unit::Assertions
        end
      end

      def step_matches(name_to_match, name_to_format)
        @step_definitions.map do |step_definition|
          if(arguments = step_definition.arguments_from(name_to_match))
            StepMatch.new(step_definition, name_to_match, name_to_format, arguments)
          else
            nil
          end
        end.compact
      end

      def matcher_text(code_keyword, step_name, multiline_arg_class, matcher_type = :regexp)
        matcher_class = typed_matcher_class(matcher_type)
        matcher_class.new(code_keyword, step_name, multiline_arg_class).to_s
      end

      def begin_rb_scenario(scenario)
        create_domain
        extend_domain
        connect_domain(scenario)
      end

      def register_rb_hook(phase, tag_expressions, proc)
        add_hook(phase, RbHook.new(self, tag_expressions, proc))
      end

      def register_rb_transform(regexp, proc)
        add_transform(RbTransform.new(self, regexp, proc))
      end

      def register_rb_step_definition(regexp, proc_or_sym, options)
        step_definition = RbStepDefinition.new(self, regexp, proc_or_sym, options)
        @step_definitions << step_definition
        step_definition
      end

      def build_rb_world_factory(domain_modules, proc)
        if(proc)
          raise MultipleDomain.new(@domain_proc, proc) if @domain_proc
          @domain_proc = proc
        end
        @domain_modules ||= []
        @domain_modules += domain_modules
      end

      def load_code_file(code_file)
        # This is what will allow self.add_step_definition, self.add_hook,
        # and self.add_transform to be called from RbLucid.
        load File.expand_path(code_file)
      end

      protected

      def begin_scenario(scenario)
        begin_rb_scenario(scenario)
      end

      def end_scenario
        @current_domain = nil
      end

      private

      def create_domain
        if(@domain_proc)
          @current_domain = @domain_proc.call
          check_nil(@current_domain, @domain_proc)
        else
          @current_domain = Object.new
        end
      end

      def extend_domain
        @current_domain.extend(RbDomain)
        @current_domain.extend(@assertions_module)
        (@domain_modules || []).each do |mod|
          @current_domain.extend(mod)
        end
      end

      def connect_domain(scenario)
        @current_domain.__lucid_runtime = @runtime
        @current_domain.__natural_language = scenario.language
      end

      def check_nil(o, proc)
        if o.nil?
          begin
            raise NilDomain.new
          rescue NilDomain => e
            e.backtrace.clear
            e.backtrace.push(proc.backtrace_line('Domain'))
            raise e
          end
        else
          o
        end
      end

      MATCHER_TYPES = {
        :regexp => Matcher::Regexp,
        :classic => Matcher::Classic,
        :percent => Matcher::Percent
      }

      def typed_matcher_class(type)
        MATCHER_TYPES.fetch(type || :regexp)
      end

      def self.cli_matcher_type_options
        MATCHER_TYPES.keys.sort_by(&:to_s).map do |type|
          MATCHER_TYPES[type].cli_option_string(type)
        end
      end
    end
  end
end
