module Lucid
  module ObjectFactory

    def create_object_of(phrase)
      attempt = 0
      begin
        attempt += 1
        parts = phrase.split('::')
        parts.shift if parts.empty? || parts.first.empty?

        obj = ::Object

        parts.each do |name|
          obj = obj.const_defined?(name, false) ? obj.const_get(name, false) : obj.const_missing(name)
        end

        obj
      rescue NameError => e
        require underscore(phrase)
        if attempt < 2
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

  end
end