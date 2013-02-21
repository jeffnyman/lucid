require "lucid/options"

module Lucid
  
  PROJECT_OPTIONS = 'lucid.yml'
  
  class App
    def initialize(args=nil)
      args ||= ARGV
      @project_options = Lucid::PROJECT_OPTIONS
      @options = Lucid::Options.parse(args)
    end
    
    def run
      
    end
    
  end
end
