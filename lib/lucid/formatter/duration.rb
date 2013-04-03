module Lucid
  module Formatter
    module Duration

      # Format a duration in seconds in the Unix time format.
      def format_duration(seconds)
        m, s = seconds.divmod(60)
        "#{m}m#{'%.3f' % s}s"
      end

    end
  end
end