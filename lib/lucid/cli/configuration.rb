require "lucid/factory"
require "lucid/cli/options"

module Lucid
  module CLI
    class Configuration
      include ObjectFactory

      class YmlLoadError < StandardError; end
      class ProfilesNotDefinedError < YmlLoadError; end
      class ProfileNotFound < StandardError; end

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        @out_stream = out_stream
        @err_stream = err_stream
        @options = Options.new(@out_stream, @err_stream, :default_profile => 'default')
      end

      def parse(args)
        @args = args
        @options.parse(args)
        prepare_output_formatting
      end

      def build_tree(runtime)
        Lucid::AST::TDLWalker.new(runtime, formatters(runtime), self)
      end

      # The spec_repo is used to get all of the files that are in the
      # "spec source" location. This location defaults to 'specs' but can
      # be changed via a command line option. The spec repo will remove
      # any directory names and, perhaps counter-intuitively, any spec
      # files. The reason for this is that, by default, the "spec repo"
      # contains everything that Lucid will need, whether that be
      # test spec files or code files to support them.
      def spec_repo
        #TODO: Should I just call spec_location here?
        requires = require_dirs
        files = requires.map do |path|
          path = path.gsub(/\\/, '/')  # convert \ to /
          path = path.gsub(/\/$/, '')  # removing trailing /
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten

        extract_excluded_files(files)

        files.reject! { |f| !File.file?(f) }
        #files.reject! { |f| File.extname(f) == '.spec' }
        files.reject! { |f| File.extname(f) == ".#{spec_type}" }
        files.sort
      end

      # The spec files refer to any files found within the spec repository
      # that match the specification file type. Note that this method is
      # called from the specs action in a Runtime instance.
      def spec_files
        files = spec_source.map do |path|
          path = path.gsub(/\\/, '/')  # convert \ to /
          path = path.chomp('/')       # removing trailing /
          if File.directory?(path)
            Dir["#{path}/**/*.#{spec_type}"].sort
          else
            path
          end
        end.flatten

        log.info("Spec Files: #{files}")

        extract_excluded_files(files)

        files
      end

      # A call to spec_location will return the location of a spec repository.
      def spec_location
        spec_source.map { |f| File.directory?(f) ? f : File.dirname(f) }
      end

      # The "spec_source" refers to the location of the spec repository. This
      # value will default to 'specs' but the value of spec_source can be
      # changed if a repository location is specified on the command line when
      # calling Lucid.
      def spec_source
        @options[:spec_source].empty? ? ['specs'] : @options[:spec_source]
        #@options[:spec_source]
      end

      # The "spec_type" refers to the file type (or extension) of spec files.
      # This is how Lucid will recognize the files that should be treated as
      # specs within a spec repository.
      def spec_type
        @options[:spec_type].empty? ? 'spec' : @options[:spec_type]
      end

      # The "library_path" refers to the location within the spec repository
      # that holds the logic that supports the basic operations of the
      # execution. This value will default to 'lucid' but the value of
      # library_path can be changed via a command line option.
      def library_path
        @options[:library_path].empty? ? 'lucid' : @options[:library_path]
      end

      # The library context will store an array of all files that are found
      # in the library_path. This path defaults to 'lucid' but can be changed
      # via a command line option.
      def library_context
        #library_files = spec_repo.select { |f| f =~ %r{/lucid/} }
        library_files = spec_repo.select { |f| f =~ %r{/#{library_path}/} }
        log.info("Library Context: #{library_files}")
        library_files
      end

      # The definition context refers to any files that are found in the spec
      # repository that are not spec files and that are not contained in the
      # library path.
      def definition_context
        #spec_repo.reject {|f| f =~ %r{/lucid/} }
        spec_repo.reject { |f| f=~ %r{/#{library_path}/} }
      end

      def verbose?
        @options[:verbose]
      end

      def debug?
        @options[:debug]
      end

      def formatter_class(name)
        if(lucid_format = Options::LUCID_FORMATS[name])
          create_object_of(lucid_format[0])
        else
          create_object_of(name)
        end
      end

      def log
        logger = Logger.new(@out_stream)
        logger.level = Logger::WARN
        logger.level = Logger::INFO  if self.verbose?
        logger.level = Logger::DEBUG if self.debug?
        logger.formatter = LogFormatter.new
        logger
      end

    private

      # TODO: Is this method really needed?
      def require_dirs
        spec_location
      end

      def extract_excluded_files(files)
        files.reject! { |path| @options[:excludes].detect { |pattern| path =~ pattern } }
      end

      def formatters(runtime)
        @options[:formats].map do |format|
          # The name will be a name, like 'standard'. The route will be the
          # location where output is sent to, such as 'STDOUT'.
          name = format[0]
          route = format[1]
          begin
            formatter = formatter_class(name)
          rescue Exception => e
            e.message << "\nLucid is unable to create the formatter: #{name}"
            raise e
          end
        end
      end

      def prepare_output_formatting
        @options[:formats] << ['standard', @out_stream] if @options[:formats].empty?
      end

    end
  end
end