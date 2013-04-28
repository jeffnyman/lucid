module Lucid
  module ObjectFactory #:nodoc:
    def create_object_of(phrase)
      try = 0
      begin
        try += 1
        names = phrase.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = ::Object
        names.each do |name|
          constant = provide_object_name(constant, name)
        end
        constant
      rescue NameError => e
        require underscore(phrase)
        if try < 2
          retry
        else
          raise e
        end
      end
    end

    def underscore(phrase)
      phrase.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    private

    def provide_object_name(constant, name)
      if constant.const_defined?(name, false)
        constant.const_get(name, false)
      else
        constant.const_missing(name)
      end
    end
  end
end
