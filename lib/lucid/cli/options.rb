require "optparse"

module Lucid
  module CLI
    class Options

      def initialize(out_stream = STDOUT, err_stream = STDERR)
        puts "Lucid::CLI::Options - initialize"
        @out_stream = out_stream
        @err_stream = err_stream
      end

      def parse(args)
        puts "Lucid::CLI::Options - parse"
        @args = args

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Lucid: Test Description Language Execution Engine",
                         "Usage: lucid [options]"].join("\n")

          opts.separator ''

          opts.on_tail("--version", "Show Lucid version information.") do
            @out_stream.puts Lucid::VERSION
            Kernel.exit(0)
          end

          opts.on_tail("-h", "--help", "Show Lucid execution information.") do
            @out_stream.puts opts.help
            Kernel.exit(0)
          end
        end.parse!

      end

    end
  end
end