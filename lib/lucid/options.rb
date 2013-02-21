require "lucid/version"
require 'optparse'

module Lucid
  class Options
    def self.parse(args)
      option_parser = OptionParser.new do |opts|
        opts.banner = ["Lucid: Test Description Language Execution Engine",
                       "Usage: lucid [options] PATTERN", ""].join("\n")
        
        opts.separator ''
        
        opts.on('-v', '--version', "Display Lucid version information.") do
          puts Lucid::VERSION
          Kernel.exit(0)
        end
        
        opts.on('-h', '--help', "Display help on how to use Lucid.") do
          puts opts
          Kernel.exit(0)
        end
      end
      
      option_parser.parse!(args)
    end
  end
end
