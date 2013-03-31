module Lucid
  module InterfaceRb
    class RbLanguage

      def initialize(facade)
        @runtime_facade = facade
      end

      def load_code_file(file)
        load File.expand_path(file)
      end

    end
  end
end