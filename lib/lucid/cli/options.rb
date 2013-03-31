require "optparse"

module Lucid
  module CLI
    class Options

      def initialize(out_stream = STDOUT, err_stream = STDERR, options = {})
        @out_stream = out_stream
        @err_stream = err_stream
        @options = default_options
      end

      def [](key)
        @options[key]
      end

      def []=(key, value)
        @options[key] = value
      end

      def parse(args)
        @args = args

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Lucid: Test Description Language Execution Engine",
                         "Usage: lucid [options]"].join("\n")

          opts.on("--library-path PATH", "Location of spec project library files.") do |path|
            @options[:library_path] = path
          end

          opts.on("--spec-type TYPE", "The file type (extension) for Lucid specifications.") do |type|
            @options[:spec_type] = type
          end

          opts.separator ''

          opts.on("--verbose", "Show detailed information about Lucid execution.") do
            @options[:verbose] = true
          end

          opts.on("--debug", "Show behind-the-scenes information about Lucid execution.") do
            @options[:debug] = true
          end

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

        # This line grabs whatever is left over on the command line. That
        # would have to be the spec repo
        @options[:spec_source] = @args.dup

        self
      end

      def default_options
        {
          :spec_type => "",
          :library_path => ""
        }
      end

    end
  end
end