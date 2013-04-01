module Lucid
  module InterfaceRb
    # It is necessary for the RbLucid module to be mixed in to the top level
    # object. This is what allows TDL test definitions and hooks to be
    # resolved as valid methods.
    module RbLucid
      class << self

        def alias_adverb(adverb)
          alias_method adverb, :register_test_definition
        end

      end

      def register_test_definition(regexp, symbol=nil, options={}, &proc)

      end
    end
  end
end

extend(Lucid::InterfaceRb::RbLucid)