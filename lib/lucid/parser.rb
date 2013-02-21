module Lucid
  class Parser
    
    def initialize(options)
      @options = options
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
    
  end # class: Parser
end # module: Lucid
