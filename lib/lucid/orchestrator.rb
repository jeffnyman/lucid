require 'lucid/factory'
require 'lucid/ast/multiline_argument'
require 'lucid/facade'

module Lucid
  class ContextLoader
    class Orchestrator

      require 'forwardable'
      class StepInvoker
        include Gherkin::Rubify

        def initialize(orchestrator)
          @orchestrator = orchestrator
        end

        def uri(uri)
        end

        def step(step)
          @orchestrator.invoke(step.name, Lucid::AST::MultilineArgument.from(step.doc_string || step.rows))
        end

        def eof
        end
      end

      include Factory

      def initialize(user_interface, context={})
        @context = Context.parse(context)
        @runtime_facade = ContextLoader::Facade.new(self, user_interface)
        @unsupported_languages = []
        @supported_languages = []
        @language_map = {}
      end

      def configure(new_context)
        @context = Context.parse(new_context)
      end

      # Invokes a series of steps +steps_text+. Example:
      #
      #   invoke(%Q{
      #     Given lucid exists
      #     Then test specs can be executed
      #   })
      def invoke_steps(steps_text, i18n, file_colon_line)
        file, line = file_colon_line.split(':')
        parser = Gherkin::Parser::Parser.new(StepInvoker.new(self), true, 'steps', false, i18n.iso_code)
        parser.parse(steps_text, file, line.to_i)
      end

      def invoke(step_name, multiline_argument=nil)
        multiline_argument = Lucid::AST::MultilineArgument.from(multiline_argument)
        begin
          step_match(step_name).invoke(multiline_argument)
        rescue Exception => e
          e.nested! if Undefined === e
          raise e
        end
      end

      # The orchestrator will register the the code language and load up an
      # implementation of that language. There is a provision to make sure
      # that the language is not already registered.
      #
      # @param type [String] the type of file, passed in as an extension value
      # @return [Object] language class
      def load_code_language(type)
        return @language_map[type] if @language_map[type]
        lucid_language = create_object_of("Lucid::Interface#{type.capitalize}::#{type.capitalize}Language")
        language = lucid_language.new(@runtime_facade)
        @supported_languages << language
        @language_map[type] = language
        language
      end

      # The orchestrator will load only the loadable execution context files.
      # This is how the orchestrator will, quite literally, orchestrate the
      # execution of specs with the code logic that supports those specs.
      #
      # @param files [Array] all files gathering for the execution context
      # @see Lucid::ContextLoader.load_execution_context
      def load_files(files)
        log.info("Orchestrator Load Files:\n")
        files.each do |file|
          load_file(file)
        end
        log.info("\n")
      end

      def load_files_from_paths(paths)
        files = paths.map { |path| Dir["#{path}/**/*"] }.flatten
        load_files files
      end

      def unmatched_step_definitions
        @supported_languages.map do |programming_language|
          programming_language.unmatched_step_definitions
        end.flatten
      end

      def matcher_text(step_keyword, step_name, multiline_arg_class)
        load_code_language('rb') if unknown_programming_language?
        @supported_languages.map do |programming_language|
          programming_language.matcher_text(step_keyword, step_name, multiline_arg_class, @context.matcher_type)
        end.join("\n")
      end

      def unknown_programming_language?
        @supported_languages.empty?
      end

      def fire_hook(name, *args)
        @supported_languages.each do |programming_language|
          programming_language.send(name, *args)
        end
      end

      def around(scenario, block)
        @supported_languages.reverse.inject(block) do |blk, programming_language|
          proc do
            programming_language.around(scenario) do
              blk.call(scenario)
            end
          end
        end.call
      end

      def step_definitions
        @supported_languages.map do |programming_language|
          programming_language.step_definitions
        end.flatten
      end

      def step_match(step_name, name_to_report=nil)
        @match_cache ||= {}

        match = @match_cache[[step_name, name_to_report]]
        return match if match

        @match_cache[[step_name, name_to_report]] = step_match_without_cache(step_name, name_to_report)
      end

      private

      def step_match_without_cache(step_name, name_to_report=nil)
        matches = matches(step_name, name_to_report)
        raise Undefined.new(step_name) if matches.empty?
        matches = best_matches(step_name, matches) if matches.size > 1 && guess_step_matches?
        raise Ambiguous.new(step_name, matches, guess_step_matches?) if matches.size > 1
        matches[0]
      end

      def guess_step_matches?
        @context.guess?
      end

      def matches(step_name, name_to_report)
        @supported_languages.map do |programming_language|
          programming_language.step_matches(step_name, name_to_report).to_a
        end.flatten
      end

      def best_matches(step_name, step_matches)
        no_groups      = step_matches.select {|step_match| step_match.args.length == 0}
        max_arg_length = step_matches.map {|step_match| step_match.args.length }.max
        top_groups     = step_matches.select {|step_match| step_match.args.length == max_arg_length }

        if no_groups.any?
          longest_regexp_length = no_groups.map {|step_match| step_match.text_length }.max
          no_groups.select {|step_match| step_match.text_length == longest_regexp_length }
        elsif top_groups.any?
          shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } }.min
          top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } == shortest_capture_length }
        else
          top_groups
        end
      end

      # For each execution context file, the orchestrator will determine the
      # code language associated with the file.
      #
      # @param file [String] relative path/file reference from the spec repo
      def load_file(file)
        language = get_language_for(file)

        if language.nil?
          log.info("  * #{file} [NOT SUPPORTED]\n")
        else
          log.info("  * #{file}\n")
          language.load_code_file(file)
        end
      end

      def log
        Lucid.logger
      end

      # The orchestrator will attempt to get the programming language for a
      # specific code file, unless that code file is marked as being an
      # unsupported language. An object is returned if the code file was part
      # of a supported language. If an object is returned it will be an
      # object of this sort:
      #     Lucid::InterfaceRb::RbLanguage
      #
      # @param file [String] relative path/file reference from the spec repo
      # @return [nil or class] full class reference if found, nil otherwise
      def get_language_for(file)
        extension = File.extname(file)[1..-1]

        if extension
          return nil if @unsupported_languages.index(extension)
          begin
            load_code_language(extension)
          rescue LoadError => e
            log.info("Unable to load '#{extension}' language for file #{file}: #{e.message}\n")
            @unsupported_languages << extension
            nil
          end
        else
          nil
        end
      end

    end
  end
end
