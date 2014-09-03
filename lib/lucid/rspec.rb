module Lucid
  module RSpec
    module SpecLoader
      def load(*files, &block)
        puts "Loading: #{files}"
        super
      end
    end
  end
end

RSpec::Core::Configuration.send(:include, Lucid::RSpec::SpecLoader)
