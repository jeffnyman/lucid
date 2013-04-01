require "lucid/interface_rb/rb_lucid"

module Lucid
  module InterfaceRb
    # This module is the Ruby implementation of the TDL API.
    class RbLanguage

      # Get the expressions of various I18n translations of TDL keywords.
      # In this case the TDL is based on Gherkin.
      Gherkin::I18n.code_keywords.each do |adverb|
        RbLucid.alias_adverb(adverb)
      end

      def initialize(facade)
        @runtime_facade = facade
      end

      def load_code_file(file)
        load File.expand_path(file)
      end

    end
  end
end