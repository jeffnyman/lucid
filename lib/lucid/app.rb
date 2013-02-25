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
      
      @specs = parser.specs
      
      puts "After calling parser for specs, I have: #{@specs.inspect}"
      
      @tags = parser.tags
      
      @message = "No specs were found matching the pattern '#{@options[:pattern]}'." and return unless @specs
      
      @command = generate_command
    end
    
    def run
      puts @message and return if @message
      @options[:print] ? puts(@command) : system("#{@command}\n\n")
    end
    
  private
  
    def generate_command
      specs = []
      steps = []
      
      command = "#{@options[:command]} #{@options[:options]}"
      
      if @specs.any?
        @specs.each do |file|
          file_parts = split_spec(file)
          specs << construct_spec_file(file_parts[:path], file_parts[:name])
        end
      else
        # If there are no spec files explicitly identified, then all of them
        # will be run. However, if non-standard locations for features or step
        # definitions are being used, that information has to be passed along.
        specs << @options[:spec_path] if @options[:non_standard_spec_path]
        ##steps << @options[:step_path] if @options[:non_standard_step_path]
      end
      
      specs << @options[:spec_path] if @options[:non_standard_spec_path]
      steps << @options[:step_path] if @options[:non_standard_step_path]
      
      requires = (@options[:requires] + steps).compact.uniq
      
      command += " -r #{requires.join(' -r ')}" if requires.any?
      command += " #{specs.join(' ')}" if specs.any?
      
      return "#{command} #{@tags}".gsub('  ', ' ')
    end
    
    def split_spec(file)
      name = File.basename(file, '.feature')
      
      # The next bit gets rid of the file name and the actual path
      # to the spec.
      path = File.dirname(file).gsub(@options[:spec_path_regex], '')
      
      return {:path => path, :name => name}
    end
    
    def construct_spec_file(path, file)
      "#{@options[:spec_path]}/#{path}/#{file}.feature".gsub('//', '/')
    end
    
  end
end
