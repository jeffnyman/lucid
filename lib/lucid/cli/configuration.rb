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

    end
  end
end