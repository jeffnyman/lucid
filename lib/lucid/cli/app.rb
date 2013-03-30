require "lucid"
require "lucid/runtime"
require "lucid/cli/configuration"

module Lucid
  module CLI
    class App

      def self.start(args)
        new(args).run
      end

      def initialize(args, out_stream = STDOUT, err_stream = STDERR)
        @args = args
        @out_stream = out_stream
        @err_stream = err_stream
      end

      def run
        runtime = Runtime.new(configuration)
        log.debug("Lucid::CLI::App - run")
      end

      def configuration
        @configuration = Configuration.new(@out_stream, @err_stream)
        @configuration.parse(@args)
        Lucid.logger = @configuration.log
        @configuration
      end

    private

      def log
        Lucid.logger
      end

    end
  end
end