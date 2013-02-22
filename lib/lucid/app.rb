require "lucid/options"
require "lucid/parser"

module Lucid
  
  PROJECT_OPTIONS = 'lucid.yml'
  
  class App
    def initialize(args=nil)
      args ||= ARGV
      @project_options = Lucid::PROJECT_OPTIONS
      @options = Lucid::Options.parse(args)
      
      parser = Lucid::Parser.new(@options)
      @tags = parser.tags
      
      @command = generate_command
    end
    
    def run
      @options[:print] ? puts(@command) : system("#{@command}\n\n")
    end
    
  private
  
    def generate_command
      specs = []
      steps = []
      
      command = "#{@options[:command]} #{@options[:options]}"
      
      specs << @options[:spec_path] if @options[:non_standard_spec_path]
      steps << @options[:step_path] if @options[:non_standard_step_path]
      
      requires = (@options[:requires] + steps).compact.uniq
      
      command += " -r #{requires.join(' -r ')}" if requires.any?
      command += " #{specs.join(' ')}" if specs.any?
      
      return "#{command} #{@tags}".gsub('  ', ' ')
    end
    
  end
end
