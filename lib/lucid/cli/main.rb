require 'gherkin'
require 'optparse'
require 'lucid'
require 'logger'
require 'lucid/parser'
require 'lucid/feature_file'
require 'lucid/cli/configuration'

module Lucid
  module CLI
    class App
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

      def start(existing_runtime = nil)
        trap_interrupt

        runtime = if existing_runtime
          existing_runtime.configure(configuration)
          existing_runtime
        else
          Runtime.new(configuration)
        end

        log.debug("Runtime: #{runtime.inspect}")

        runtime.run!
        runtime.write_stepdefs_json
        failure = runtime.results.failure? || Lucid.wants_to_quit
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

        @configuration = Configuration.new(@out, @err)
        @configuration.parse(@args)
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
          STDERR.puts "\nExiting. Interrupt again to exit immediately."
        end
      end
    end
  end
end
