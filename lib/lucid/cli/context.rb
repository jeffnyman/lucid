require 'lucid/cli/options'
require 'lucid/factory'
require 'gherkin/tag_expression'

module Lucid
  module CLI
    class YmlLoadError < StandardError; end
    class ProfilesNotDefinedError < YmlLoadError; end
    class ProfileNotFound < StandardError; end

    class Context
      include Factory

      attr_reader :out_stream

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        @out_stream = out_stream
        @err_stream = err_stream
        @options = Options.new(@out_stream, @err_stream, :default_profile => 'default')
      end

      def parse_options(args)
        @args = args
        @options.parse(args)
        log.debug('Options:')
        log.debug(@options)

        set_formatter
        raise('You cannot use both --strict and --wip tags.') if strict? && wip?

        @options[:tag_expression] = Gherkin::TagExpression.new(@options[:tag_expressions])

        set_environment_variables
      end

      def verbose?
        @options[:verbose]
      end

      def debug?
        @options[:debug]
      end

      def strict?
        @options[:strict]
      end

      def wip?
        @options[:wip]
      end

      def guess?
        @options[:guess]
      end

      def dry_run?
        @options[:dry_run]
      end

      def expand?
        @options[:expand]
      end

      def testdefs
        @options[:testdefs]
      end

      def matcher_type
        @options[:matcher_type] || :regexp
      end

      # @see Lucid::ContextLoader.execute
      def establish_ast_walker(runtime)
        Lucid::AST::Walker.new(runtime, formatters(runtime), self)
      end

      def formatter_instance(name)
        if lucid_format = Options::LUCID_FORMATS[name]
          create_object_of(lucid_format[0])
        else
          create_object_of(name)
        end
      end

      # @return [Array] list of non-spec, executable files from all required locations
      def spec_requires
        requires = @options[:require].empty? ? require_dirs : @options[:require]

        files = requires.map do |path|
          path = path.gsub(/\\/, '/')
          path = path.gsub(/\/$/, '')
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten.uniq

        extract_excluded_files(files)

        files.reject! {|f| !File.file?(f)}

        spec_type.each do |type|
          files.reject! {|f| File.extname(f) == ".#{type}" }
        end

        files.reject! {|f| f =~ /^http/}

        files.sort
      end

      # Returns all definition files that exist in the default or provided
      # execution path.
      #
      # @return [Array] executable files outside of the library path
      # @see Lucid::ContextLoader.load_execution_context
      def definition_context
        definition_files = spec_requires.reject { |f| f =~ %r{#{library_path}} }
        log.info("Definition Files:\n#{definition_files}")

        non_test_definitions = spec_requires.reject { |f| f =~ %r{#{steps_path}|#{library_path}} }
        log.info("Non-Test Definition Files:\n#{non_test_definitions}")

        @options[:dry_run] ? definition_files - non_test_definitions : definition_files
      end

      # Returns all library files that exist in the default or provided
      # library path. During a dry run, the driver file will not be
      # returned as part of the executing context.
      #
      # @return [Array] valid executable files in the library path
      # @see Lucid::ContextLoader.load_execution_context
      def library_context
        library_files = spec_requires.select { |f| f =~ %r{#{library_path}} }
        log.info("Library Files:\n#{library_files}")

        driver = library_files.select {|f| f =~ %r{#{driver_file}} }
        log.info("Driver File:\n#{driver}")

        non_driver_files = library_files - driver

        @options[:dry_run] ? non_driver_files : driver + non_driver_files
      end

      # Returns all spec files that exist in the default or provided spec
      # repository.
      #
      # @return [Array] spec files from the repo
      # @see Lucid::RepoRunner.load_spec_context
      def spec_context
        files = specs_path(spec_source).map do |path|
          path = path.gsub(/\\/, '/')
          path = path.chomp('/')

          files_to_sort = []

          if File.directory?(path)
            spec_type.each do |type|
              files_to_sort << Dir["#{path}/**/*.#{type}"].sort
            end

            files_to_sort
          elsif path[0..0] == '@' and # @listfile.txt
            File.file?(path[1..-1]) # listfile.txt is a file
            IO.read(path[1..-1]).split
          else
            path
          end
        end.flatten.uniq

        extract_excluded_files(files)

        files
      end

      def spec_location
        dirs = spec_source.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
        dirs.delete('.') unless spec_source.include?('.')

        specs_path(dirs)
      end

      def spec_type
        @options[:spec_types]
      end

      def library_path
        @options[:library_path]
      end

      def driver_file
        @options[:driver_file]
      end

      def steps_path
        @options[:steps_path]
      end

      def definitions_path
        @options[:definitions_path]
      end

      def log
        logger = Logger.new(@out_stream)
        logger.formatter = LogFormatter.new
        logger.level = Logger::WARN
        logger.level = Logger::INFO  if self.verbose?
        logger.level = Logger::DEBUG if self.debug?
        logger
      end

      def tag_expression
        Gherkin::TagExpression.new(@options[:tag_expressions])
      end

      def filters
        @options.filters
      end

      def formats
        @options[:formats]
      end

      def spec_source
        @options[:spec_source]
      end

      private

      def specs_path(paths)
        return ['specs'] if paths.empty?
        paths
      end

      def formatters(runtime)
        @options[:formats].map do |format|
          begin
            formatter = formatter_instance(format[0])
            formatter.new(runtime, format[1], @options)
          rescue LoadError
            message = "\nLucid is unable to create the formatter: #{format[0]}"
            log.error(message)
            Kernel.exit(1)
          end
        end
      end

      def set_environment_variables
        @options[:env_vars].each do |var, value|
          ENV[var] = value
        end
      end

      def set_formatter
        @options[:formats] << ['standard', @out_stream] if @options[:formats].empty?
        @options[:formats] = @options[:formats].sort_by{|f| f[1] == @out_stream ? -1 : 1}
        @options[:formats].uniq!

        streams = @options[:formats].map { |(_, stream)| stream }

        if streams != streams.uniq
          raise 'All but one formatter must use --out, only one can print to each stream (or STDOUT)'
        end
      end

      def extract_excluded_files(files)
        files.reject! {|path| @options[:excludes].detect {|pattern| path =~ pattern } }
      end

      def require_dirs
        spec_location + Dir["#{library_path}", "#{definitions_path}", "#{steps_path}"]
      end

    end

  end
end
