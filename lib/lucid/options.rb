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
        
        opts.on('-t', '--tags TAGS', "Tags to include or exclude.") do |tags|
          combine_options[:tags] = tags
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
      
      # This statement is necessary to get the spec execution pattern from
      # the command line. This will not be a switch and so it will be the
      # only actual command line argument.
      combine_options[:pattern] = args.first if args.any?
      
      return self.establish(combine_options)
    end
    
  private
  
    def self.get_options(type = :default)
      if type == :project
        project_options = {}
        
        if File.exist?(Lucid::PROJECT_OPTIONS)
          yaml_options = YAML.load_file(Lucid::PROJECT_OPTIONS)
          
          # Do I need to pass spec_path_regex here? I thought I did due to
          ['command', 'options', 'spec_path', 'step_path', 'requires', 'shared', 'spec_path_regex'].each do |key|
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
          :command         => 'cucumber',     # :cuke_command
          :options         => nil,            # :cucumber
          :spec_path       => 'features',     # :feature_path
          :step_path       => 'features/step_definitions',
          :requires        => [],
          :shared          => 'true',         # value was 'shared'
          :print           => false,
          :tags            => nil,
          :spec_path_regex => nil,
          :step_path_regex => nil,
          :pattern         => nil
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
      
      unless current_set[:pattern].nil?
        current_set[:pattern] = current_set[:pattern].gsub(/\\/, '/')
        current_set[:pattern] = current_set[:pattern].sub(/\/$/, '')
      end
      
      # Establish that the spec path and the step path are not the standard
      # values that Cucumber would expect by default.
      current_set[:non_standard_spec_path] = current_set[:spec_path] != defaults[:spec_path]
      current_set[:non_standard_step_path] = current_set[:step_path] != defaults[:step_path]
      
      # Create a regular expression from the spec path and the step path.
      # This is done so that Lucid can look at the paths dynamically, mainly
      # when dealing with shared steps.
      current_set[:spec_path_regex] = Regexp.new(current_set[:spec_path].gsub('/', '\/')) unless current_set[:spec_path_regex]
      current_set[:step_path_regex] = Regexp.new(current_set[:step_path].gsub('/', '\/')) unless current_set[:step_path_regex]
      
      # If the values are set to nil, the following commands make sure to
      # revert to the defaults.
      current_set[:spec_path] ||= defaults[:spec_path]
      current_set[:step_path] ||= defaults[:step_path]
      current_set[:requires] ||= defaults[:requires]
      current_set[:command] ||= defaults[:command]
      
      # The shared setting has to be something that Lucid can use.
      shared = current_set[:shared].nil? ? 'true' : current_set[:shared].to_s.strip
      shared = 'true' if shared.strip == ''
      
      # Here the shared value is established based on a few likely usage
      # patterns for it. Note that if one of these usage patterns is not
      # used, then shared will be kept at whatever setting it has.
      if ['shared', 'yes', ''].include?(shared.downcase)
        shared == true
      elsif ['false', 'no'].include?(shared.downcase)
        shared == false
      end
      
      current_set[:shared] = shared
      
      # The pattern that was specified must be handled to make sure it is
      # something that can be worked with.
      unless current_set[:pattern].nil?
        current_set[:pattern] = current_set[:pattern].strip
        current_set[:pattern] = nil unless current_set[:pattern] && !current_set[:pattern].empty?
      end
      
      return current_set
    end
    
  end # class: Options
end # module: Lucid
