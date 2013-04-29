require 'lucid/cli/options'
require 'lucid/factory'
require 'gherkin/tag_expression'

module Lucid
  module CLI
    class YmlLoadError < StandardError; end
    class ProfilesNotDefinedError < YmlLoadError; end
    class ProfileNotFound < StandardError; end

    class Configuration
      include ObjectFactory

      attr_reader :out_stream

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        @out_stream   = out_stream
        @err_stream = err_stream
        @options = Options.new(@out_stream, @err_stream, :default_profile => 'default')
      end

      def parse(args)
        @args = args
        @options.parse(args)
        log.debug("Options: #{@options.inspect}")

        prepare_output_formatting
        raise("You cannot use both --strict and --wip tags.") if strict? && wip?

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

      def snippet_type
        @options[:snippet_type] || :regexp
      end

      def establish_tdl_walker(runtime)
        Ast::TDLWalker.new(runtime, formatters(runtime), self)
      end

      def formatter_class(name)
        if(lucid_format = Options::LUCID_FORMATS[name])
          create_object_of(lucid_format[0])
        else
          create_object_of(name)
        end
      end

      # The spec_repo is used to get all of the files that are in the
      # "spec source" location. This location defaults to 'specs' but can
      # be changed via a command line option. The spec repo will remove
      # any directory names and, perhaps counter-intuitively, any spec
      # files. The reason for this is that, by default, the "spec repo"
      # contains everything that Lucid will need, whether that be
      # test spec files or code files to support them.
      def spec_repo
        requires = @options[:require].empty? ? require_dirs : @options[:require]

        files = requires.map do |path|
          path = path.gsub(/\\/, '/')   # convert \ to /
          path = path.gsub(/\/$/, '')   # removing trailing /
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten.uniq

        extract_excluded_files(files)

        files.reject! {|f| !File.file?(f)}
        files.reject! {|f| File.extname(f) == '.feature' }
        files.reject! {|f| f =~ /^http/}
        files.sort
      end

      # The definition context refers to any files that are found in the spec
      # repository that are not spec files and that are not contained in the
      # library path.
      # @see Lucid::Runtime.load_execution_context
      def definition_context
        spec_repo.reject {|f| f =~ %r{/support/} }
      end

      # The library context will store an array of all files that are found
      # in the library_path. This path defaults to 'lucid' but can be changed
      # via a command line option.
      # @see Lucid::Runtime.load_execution_context
      def library_context
        support_files = spec_repo.select {|f| f =~ %r{/support/} }
        env_files = support_files.select {|f| f =~ %r{/support/env\..*} }
        other_files = support_files - env_files
        @options[:dry_run] ? other_files : env_files + other_files
      end

      # The spec files refer to any files found within the spec repository
      # that match the specification file type. Note that this method is
      # called from the specs action in a Runtime instance.
      # @see Lucid::Runtime.specs
      def spec_files
        files = with_default_features_path(spec_source).map do |path|
          path = path.gsub(/\\/, '/')  # convert \ to /
          path = path.chomp('/')       # removing trailing /
          if File.directory?(path)
            Dir["#{path}/**/*.feature"].sort
          elsif path[0..0] == '@' and # @listfile.txt
              File.file?(path[1..-1]) # listfile.txt is a file
            IO.read(path[1..-1]).split
          else
            path
          end
        end.flatten.uniq

        log.info("Spec Files: #{files}")

        extract_excluded_files(files)
        files
      end

      # A call to spec_location will return the location of a spec repository.
      def spec_location
        dirs = spec_source.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
        dirs.delete('.') unless spec_source.include?('.')

        # TODO: Should I be doing this? (See commented line in spec_source)
        with_default_features_path(dirs)
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

      # The "spec_source" refers to the location of the spec repository. This
      # value will default to 'specs' but the value of spec_source can be
      # changed if a repository location is specified on the command line when
      # calling Lucid.
      def spec_source
        @options[:paths]
        #@options[:spec_source].empty? ? ['specs'] : @options[:spec_source]
      end

    private

      def with_default_features_path(paths)
        return ['features'] if paths.empty?
        paths
      end

      def formatters(runtime)
        # TODO: Remove the autoformat functionality; use the Gherkin CLI instead.
        if @options[:autoformat]
          require 'lucid/formatter/standard'
          return [Formatter::Standard.new(runtime, nil, @options)]
        end

        @options[:formats].map do |format|
          # The name will be a name, like 'standard'. The route will be the
          # location where output is sent to, such as 'STDOUT'.
          name = format[0]
          route = format[1]
          begin
            formatter = formatter_class(name)
            formatter.new(runtime, route, @options)
          rescue Exception => e
            e.message << "\nLucid is unable to create the formatter: #{name}"
            raise e
          end
        end
      end

      def set_environment_variables
        @options[:env_vars].each do |var, value|
          ENV[var] = value
        end
      end

      def prepare_output_formatting
        @options[:formats] << ['standard', @out_stream] if @options[:formats].empty?
        @options[:formats] = @options[:formats].sort_by{|f| f[1] == @out_stream ? -1 : 1}
        @options[:formats].uniq!

        streams = @options[:formats].map { |(_, stream)| stream }

        if streams != streams.uniq
          raise "All but one formatter must use --out, only one can print to each stream (or STDOUT)"
        end
      end

      def extract_excluded_files(files)
        files.reject! {|path| @options[:excludes].detect {|pattern| path =~ pattern } }
      end

      def require_dirs
        spec_location + Dir['vendor/{gems,plugins}/*/lucid']
      end

    end

  end
end
