require "lucid/version"
require 'optparse'
require 'yaml'

module Lucid
  class Options
    def self.parse(args)
      default_options = self.get_options(:default)
      project_options = self.get_options(:project)
      combine_options = default_options.merge(project_options)
      
      option_parser = OptionParser.new do |opts|
        opts.banner = ["Lucid: Test Description Language Execution Engine",
                       "Usage: lucid [options] PATTERN", ""].join("\n")
        
        opts.separator ''
        
        opts.on('-p', '--print', "Echo the Lucid command instead of executing it.") do
          combine_options[:print] = true
        end
        
        opts.on('-o', '--options OPTIONS', "Options to pass to the tool.") do |options|
          combine_options[:options] = options
        end
        
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
      
      return self.establish(combine_options)
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
        
        project_options
      else
        {
          :command   => 'cucumber',     # :cuke_command
          :options   => nil,            # :cucumber
          :spec_path => 'features',     # :feature_path
          :step_path => 'features/step_definitions',
          :requires  => [],
          :print     => false
        }
      end
      
    end
    
    def self.establish(options)
      defaults = self.get_options(:default)
      
      current_set = options.dup  # tmp_options
      
      current_set[:spec_path] = current_set[:spec_path].gsub(/\\/, '/')
      current_set[:spec_path] = current_set[:spec_path].sub(/\/$/, '')
      
      current_set[:step_path] = current_set[:step_path].gsub(/\\/, '/')
      current_set[:step_path] = current_set[:step_path].sub(/\/$/, '')
      
      # Establish that the spec path and the step path are not the standard
      # values that Cucumber would expect by default.
      current_set[:non_standard_spec_path] = current_set[:spec_path] != defaults[:spec_path]
      current_set[:non_standard_step_path] = current_set[:step_path] != defaults[:step_path]
      
      # If the values are set to nil, the following commands make sure to
      # revert to the defaults.
      current_set[:spec_path] ||= defaults[:spec_path]
      current_set[:step_path] ||= defaults[:step_path]
      current_set[:requires] ||= defaults[:requires]
      current_set[:command] ||= defaults[:command]
      
      return current_set
    end
    
  end # class: Options
end # module: Lucid
