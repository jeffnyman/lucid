module Lucid
  
  PROJECT_OPTIONS = 'lucid.yml'
  
  class App
    def initialize(args=nil)
      puts "Initialize method called."
      @project_options = Lucid::PROJECT_OPTIONS
    end
    
    def run
      puts "Run method called."
    end
    
  end
end
