require 'lucid/formatter/standard'

module Lucid
  module Formatter
    class Condensed < Lucid::Formatter::Standard
      
      def scenario_name(keyword, name, file_colon_line, source_indent)
        super
      end

      def feature_name(keyword, name)
        name = name.split(/\n/)[0]
        @io.puts("#{keyword}: #{name}")
        @io.flush
      end

      def background_name(*args)
        return
      end

      def before_step( step )
        @io.print "\r... #{step.name}"
        @io.flush
      end

      def after_step( step )
        @io.print " "*(step.name.length+4)
        @io.flush
      end

      def before_step_result( *args )
        @io.printf "\r"
        super
      end

      def step_name(*args)
        @hide_this_step=true if args[2] == :passed
        super
      end

      def comment_line(comment_line)
        return
      end
    end
  end
end
