require 'optparse'

module Spec #:nodoc:
  module Runner #:nodoc:
    # Lucid uses OptionParser in order to parse any command line options.
    # If RSpec is being used in any way with Lucid, then what will happen
    # is that RSpec's option parser will kick in and try to parse ARGV.
    # Since the command line arguments will be specific to Lucid, RSpec
    # will not know what to do with them and will fail. So what this bit
    # of logic is doing is making sure that the option parser for RSpec
    # will not be operative.
    class OptionParser < ::OptionParser #:nodoc:
      MODDED_RSPEC = Object.new
      def MODDED_RSPEC.method_missing(m, *args); self; end

      def self.method_added(m)
        unless @__modding_rspec
          @__modding_rspec = true
          define_method(m) do |*a|
            MODDED_RSPEC
          end
          @__modding_rspec = false
        end
      end
    end
  end
end
