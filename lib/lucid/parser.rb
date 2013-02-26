module Lucid
  class Parser
    
    def initialize(options)
      @options = options
    end
    
    def specs
      #puts "[Parser.specs] Is @options[:pattern] nil? #{@options[:pattern].nil?}"
      return [] if @options[:pattern].nil?
      
      set_of_specs = gather_specs_by_glob
      
      #puts "[Parser.specs] Were there any specs? #{set_of_specs.any?}"
      
      return set_of_specs.any? ? set_of_specs : nil
    end
    
    def tags
      tags = {
        :or  => [],
        :and => [],
        :not => []
      }
      
      return '' if @options[:tags].nil?
      
      @options[:tags].split(',').each do |tag|
        # Tags that are numeric can be ranged.
        if tag =~ /^(~)?([0-9]+)-([0-9]+)$/
          x = $2.to_i
          y = $3.to_i
          exclude = $1
          
          # Make sure numeric tags are in numerical order.
          if x > y
            hold_x = x.dup
            x = y.dup
            y = hold_x.dup
          end
          
          (x..y).each do |capture|
            if exclude
              tags[:not] << "#{capture}"
            else
              tags[:or] << "#{capture}"
            end
          end
        else
          if tag =~ /^~(.+)/
            tags[:not] << $1
          elsif tag =~ /^\+(.+)/
            tags[:and] << $1
          else
            tags[:or] << tag
          end
        end
      end # each
      
      [:and, :or, :not].each { |type| tags[type].uniq! }
      
      intersection = tags[:or] & tags[:not]
      tags[:or] -= intersection
      tags[:not] -= intersection
      
      intersection = tags[:and] & tags[:not]
      tags[:and] -= intersection
      tags[:not] -= intersection
      
      tags[:or].each_with_index { |tag, i| tags[:or][i] = "@#{tag}" }
      tags[:and].each_with_index { |tag, i| tags[:and][i] = "@#{tag}" }
      tags[:not].each_with_index { |tag, i| tags[:not][i] = "~@#{tag}" }
      
      tag_builder = ''
      tag_builder += "-t #{tags[:or].join(',')} " if tags[:or].any?
      tag_builder += "-t #{tags[:and].join(' -t ')} " if tags[:and].any?
      tag_builder += "-t #{tags[:not].join(' -t ')}" if tags[:not].any?
      
      tag_builder.gsub!('@@', '@')
      tag_builder
    end # method: tags
    
  private
  
    def gather_specs_by_glob
      only = []
      except = []
      specs_to_include = []
      specs_to_exclude = []
      
      pattern = @options[:pattern].dup
      
      #puts "[Parser.gather_specs_by_glob] The pattern is: #{pattern}"
      
      # Determine if some specs were indicated to be excluded
      # and mark those separately. This also handles when only
      # specific specs are to be executed.
      pattern.split(',').each do |f|
        if f[0].chr == '~'
          except << f[1..f.length]
        else
          only << f
        end
      end
      
      # If there are exceptions, then all specs should be
      # gathered by default. Unless, that is, the command
      # indicates that only certain specs should be run.
      pattern = '**/*' if except.any?
      pattern = nil if only.any?
      
      #puts "[Parser.gather_specs_by_glob] Is the pattern after only/except nil?: #{pattern.nil?}"
      #puts "[Parser.gather_specs_by_glob] The @options[:spec_path] is: #{@options[:spec_path]}"      
      
      if only.any?
        only.each do |f|
          #puts "[Parser.gather_specs_by_glob] There is an only and it is: #{f}"
          
          #specs_to_include += Dir.glob("#{@options[:spec_path]}/#{f}.feature")
          specs_to_include += Dir.glob("#{f}")
        end
      else
        #puts "[Parser.gather_specs_by_glob] There is no only so pattern is: #{pattern}"
        specs_to_include += Dir.glob("#{@options[:spec_path]}/#{pattern}.feature")
      end
      
      #puts "[Parser.gather_specs_by_glob] After checking only, specs_to_include is: #{specs_to_include}"
      
      if except.any?
        except.each do |f|
          #puts "[Parser.gather_specs_by_glob] There is an except and it is: #{f}"
          specs_to_exclude = Dir.glob("#{@options[:spec_path]}/#{f}.feature")
        end
      end
      
      #puts "[Parser.gather_specs_by_glob] Returning #{specs_to_include - specs_to_exclude}"
      
      (specs_to_include - specs_to_exclude).uniq
    end
    
  end # class: Parser
end # module: Lucid
