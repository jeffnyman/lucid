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
      #puts "[App.initialize] After calling parser for specs, I have: #{@specs.inspect}"
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
          specs << construct_spec_file(file_parts[:path], file_parts[:name], file_parts[:full_name])
        end
      else
        # If there are no spec files explicitly identified, then all of them
        # will be run. However, if non-standard locations for features or step
        # definitions are being used, that information has to be passed along.
        specs << @options[:spec_path] if @options[:non_standard_spec_path]
        ##steps << @options[:step_path] if @options[:non_standard_step_path]
      end
      
      need_root = nil
      
      specs.each do |spec|
        start_path = spec[0..spec.index("/") - 1] unless spec.index("/").nil?
        start_path = spec if spec.index("/").nil?
        
        if start_path != @options[:spec_path]
          need_root = true
        end
      end
      
      specs << @options[:spec_path] if @options[:non_standard_spec_path] unless need_root.nil?
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
      
      return {:path => path, :name => name, :full_name => file}
    end
    
    def construct_spec_file(path, file, file_name)
      #puts "[App.construct_spec_file] Path = #{path} || File = #{file} || File name = #{file_name}"
      
      construct = ""
      
      # If the file that is passed in matches the name of the specs path
      # then the assumption is that the user specified the main specs path
      # to be executed, such as with "lucid specs". If the information
      # provided does not end with ".feature" then it is assumed that a
      # full directory is being referenced.
      if file == @options[:spec_path]
        construct = "#{file}"
      elsif file_name[-8, 8] == ".feature" #not file =~ /\.feature$/
        construct = "#{file_name}".gsub('//', '/')
      else
        #construct = "#{@options[:spec_path]}/#{path}/#{file}.feature".gsub('//', '/')
        construct = "#{file_name}".gsub('//', '/')
      end
      
      #puts "[App.construct_spec_file] Construct = #{construct}"
      
      construct
    end
    
  end
end
