require 'timeout'

module Lucid
  class Runtime

    module InterfaceIO
      attr_writer :visitor

      def puts(*messages)
        @visitor.puts(*messages)
      end

      def ask(question, timeout_seconds)
        STDOUT.puts(question)
        STDOUT.flush
        puts(question)

        if(Lucid::JRUBY)
          answer = jruby_gets(timeout_seconds)
        else
          answer = mri_gets(timeout_seconds)
        end

        if(answer)
          puts(answer)
          answer
        else
          raise("Lucid waited for input for #{timeout_seconds} seconds, then timed out.")
        end
      end

      def embed(src, mime_type, label)
        @visitor.embed(src, mime_type, label)
      end

    private

      def mri_gets(timeout_seconds)
        begin
          Timeout.timeout(timeout_seconds) do
            STDIN.gets
          end
        rescue Timeout::Error
          nil
        end
      end

      def jruby_gets(timeout_seconds)
        answer = nil
        t = java.lang.Thread.new do
          answer = STDIN.gets
        end
        t.start
        t.join(timeout_seconds * 1000)
        answer
      end
    end

  end
end
