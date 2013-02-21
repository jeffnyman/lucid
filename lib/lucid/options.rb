require "lucid/version"
require 'optparse'
require 'yaml'

module Lucid
  class Options
    def self.parse(args)
      default_options = self.get_options(:default)
      project_options = self.get_options(:project)
      
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
    
  private
  
    def self.get_options(type = :default)
      if type == :project
        project_options = {}
        
        if File.exist?(Lucid::PROJECT_OPTIONS)
          yaml_options = YAML.load_file(Lucid::PROJECT_OPTIONS)
          
          ['command', 'options', 'spec_path', 'step_path', 'requires'].each do |key|
            begin
              project_options[key.to_sym] = yaml_options[key] if yaml_options.has_key?(key)
            rescue NoMethodError
              # noop
            end
          end
        end
        
        puts "**** Project Options: #{project_options}"
        
        project_options
      end
      
      if type == :default
        {
          :command   => 'cucumber',     # :cuke_command
          :options   => nil,            # :cucumber
          :spec_path => 'features',     # :feature_path
          :step_path => 'features/step_definitions',
          :requires  => []
        }
      end
      
    end
    
  end # class: Options
end # module: Lucid
