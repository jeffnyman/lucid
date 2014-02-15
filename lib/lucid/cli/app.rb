require 'gherkin'
require 'optparse'
require 'lucid'
require 'logger'
require 'lucid/spec_file'
require 'lucid/cli/context'

module Lucid
  module CLI
    class App
      def self.start(args)
        new(args).start!
      end

      def initialize(args, stdin=STDIN, out=STDOUT, err=STDERR, kernel=Kernel)
        raise "args can't be nil" unless args
        raise "out can't be nil" unless out
        raise "err can't be nil" unless err
        raise "kernel can't be nil" unless kernel
        @args   = args
        @out    = out
        @err    = err
        @kernel = kernel
        @configuration = nil
      end

      def start!(existing_context = nil)
        trap_interrupt

        context_loader = if existing_context
          existing_context.configure(configuration)
          existing_context
        else
          ContextLoader.new(configuration)
        end

        log.debug("Context Loader: #{context_loader.inspect}")

        context_loader.execute
        context_loader.write_testdefs_json
        failure = context_loader.results.failure? || Lucid.wants_to_quit
        @kernel.exit(failure ? 1 : 0)
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @err.puts(e.message)
      rescue SystemExit => e
        @kernel.exit(e.status)
      rescue Errno::EACCES, Errno::ENOENT => e
        @err.puts("#{e.message} (#{e.class})")
        @kernel.exit(1)
      rescue Exception => e
        @err.puts("#{e.message} (#{e.class})")
        @err.puts(e.backtrace.join("\n"))
        @kernel.exit(1)
      end

      def configuration
        return @configuration if @configuration

        @configuration = Context.new(@out, @err)
        @configuration.parse_options(@args)
        Lucid.logger = @configuration.log
        log.debug("Configuration: #{@configuration.inspect}")
        @configuration
      end

      private

      def log
        Lucid.logger
      end

      def trap_interrupt
        trap('INT') do
          exit!(1) if Lucid.wants_to_quit
          Lucid.wants_to_quit = true
          STDERR.puts "\nExiting Lucid execution.\nInterrupt again to exit immediately."
        end
      end
    end
  end
end
