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
        @args   = args
        @out    = out
        @err    = err
        @kernel = kernel
        @context = nil
      end

      def start!(existing_context=nil)
        trap_interrupt

        context_loader = if existing_context
          existing_context.configure(load_context)
          existing_context
        else
          ContextLoader.new(load_context)
        end

        log.debug('Context Loader')
        log.debug(context_loader)

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

      def load_context
        return @context if @context

        @context = Context.new(@out, @err)
        @context.parse_options(@args)
        Lucid.logger = @context.log
        log.debug('Context:')
        log.debug(@context)
        @context
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
