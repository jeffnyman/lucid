require "lucid"
require "lucid/runtime"
require "lucid/cli/configuration"

module Lucid
  module CLI
    class App

      def self.start(args)
        puts "Lucid::CLI::App - start"
        new(args).run
      end

      def initialize(args, out_stream = STDOUT, err_stream = STDERR)
        puts "Lucid::CLI::App - initialize"
        @args = args
        @out_stream = out_stream
        @err_stream = err_stream
      end

      def run
        puts "Lucid::CLI::App - run"
        runtime = Runtime.new(configuration)
      end

      def configuration
        @configuration = Configuration.new(@out_stream, @err_stream)
        @configuration.parse(@args)
      end

    end
  end
end