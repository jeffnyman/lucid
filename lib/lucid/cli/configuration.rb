require "lucid/cli/options"

module Lucid
  module CLI
    class Configuration

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        @out_stream = out_stream
        @err_stream = err_stream
        @options = Options.new(@out_stream, @err_stream)
      end

      def parse(args)
        @args = args
        @options.parse(args)
      end

      # The spec_repo is used to get all of the files that are in the
      # "spec source" location. This location defaults to 'specs' but can
      # be changed via a command line option. The spec repo will remove
      # any directory names and, perhaps counter-intuitively, any spec
      # files. The reason for this is that, by default, the "spec repo"
      # contains everything that Lucid will need, whether that be
      # test spec files or code files to support them.
      def spec_repo
        log.debug("Lucid::CLI::Configuration - spec_repo")
        #TODO: Should I just call spec_location here?
        requires = require_dirs
        files = requires.map do |path|
          path = path.gsub(/\\/, '/')  # convert \ to /
          path = path.gsub(/\/$/, '')  # removing trailing /
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten

        files.reject! { |f| !File.file?(f) }
        files.reject! { |f| File.extname(f) == '.spec' }
        files.sort
      end

      # A call to spec_location will return the location of a spec repository.
      def spec_location
        log.debug("Lucid::CLI::Configuration - spec_location")
        spec_source.map { |f| File.directory?(f) ? f : File.dirname(f) }
      end

      # The "spec_source" refers to the location of the spec repository. This
      # value will default to 'specs' but the value of spec_source can be
      # changed if a repository location is specified on the command line when
      # calling Lucid.
      def spec_source
        log.debug("Lucid::CLI::Configuration - spec_source")
        @options[:spec_source].empty? ? ['specs'] : @options[:spec_source]
        #@options[:spec_source]
      end

      # The library context will store an array of all files that are found
      # in the library_path. This path defaults to 'lucid' but can be changed
      # via a command line option.
      def library_context
        log.debug("Lucid::CLI::Configuration - library_context")
        library_files = spec_repo.select { |f| f =~ %r{/lucid/} }
        log.info("Library Context: #{library_files}")
        library_files
      end

      # The definition context refers to any files that are found in the spec
      # repository that are not spec files and that are not contained in the
      # library path.
      def definition_context
        spec_repo.reject {|f| f =~ %r{/lucid/} }
      end

      def verbose?
        @options[:verbose]
      end

      def debug?
        @options[:debug]
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
        log.debug("Lucid::CLI::Configuration - require_dirs")
        spec_location
      end
    end
  end
end