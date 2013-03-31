require "lucid/factory"
require "lucid/runtime/facade"

module Lucid
  class Runtime
    class Orchestrator
      include ObjectFactory

      def initialize(interface, configuration)
        @configuration = configuration
        @runtime_facade = Runtime::Facade.new(self, interface)
        @unsupported_languages = []
        @supported_languages = []
        @language_map = {}
      end

      # The orchestrator will load only the loadable execution context files.
      # This is how the orchestrator will, quite literally, orchestrate the
      # execution of specs with the code logic that supports those specs.
      def load_files(files)
        log.info("Orchestrator Load Files:\n")
        files.each do |file|
          load_file(file)
        end
        log.info("\n")
      end

      # The orchestrator will register the the code language and load up an
      # implementation of that language. There is a provision to make sure
      # that the language is not already registered.
      def load_code_language(code)
        return @language_map[code] if @language_map[code]
        lucid_language = create_object_of("Lucid::Interface#{code.capitalize}::#{code.capitalize}Language")
        language = lucid_language.new(@runtime_facade)
        @supported_languages << language
        @language_map[code] = language
        language
      end

    private

      # For each execution context file, the orchestrator will determine the
      # code language associated with the file.
      def load_file(file)
        if language = get_language_for(file)
          log.info("  * #{file}\n")
          language.load_code_file(file)
        else
          log.info("  * #{file} [UNSUPPORTED]\n")
        end
      end

      # The orchestrator will attempt to get the programming language for a
      # specific code file, unless that code file is marked as being an
      # unsupported language. An object is returned if the code file was part
      # of a supported language. If an object is returned it will be an
      # object of this sort:
      #     Lucid::InterfaceRb::RbLanguage
      def get_language_for(file)
        if extension = File.extname(file)[1..-1]
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

      def log
        Lucid.logger
      end
    end
  end
end