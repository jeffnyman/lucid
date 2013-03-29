require "lucid/cli/options"

module Lucid
  module CLI
    class Configuration

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        puts "Lucid::CLI::Configuration - initialize"
        @out_stream = out_stream
        @err_stream = err_stream
        @options = Options.new(@out_stream, @err_stream)
      end

      def parse(args)
        puts "Lucid::CLI::Configuration - parse"
        @args = args
        @options.parse(args)
      end

    end
  end
end