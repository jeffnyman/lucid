module Lucid
  module Factory
    # @param type [String] Object representation
    def create_object_of(type)
      require path_for_type(type)

      names = parse_type(type)
      constant = ::Object

      names.each do |name|
        constant = provide_object_name(constant, name)
      end

      constant
    end

    private

    def path_for_type(type)
      type.to_s.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
    end

    def parse_type(type)
      names = type.split('::')
      names.shift if names.empty? || names.first.empty?
      names
    end

    # @param constant [Object] class or module reference
    # @param name [String] class or module reference
    def provide_object_name(constant, name)
      if constant.const_defined?(name, false)
        constant.const_get(name, false)
      else
        constant.const_missing(name)
      end
    end
  end
end
