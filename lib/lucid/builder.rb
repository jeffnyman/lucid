require 'gherkin'

module Lucid
  class Builder
    class << self
      def build(test_spec)
        puts "Attempting to build: #{test_spec}" if ENV['LUCID_TRACE']
        Lucid::Builder.new.tap do |builder|
          # Builder instance is yielded to the block.
          # The builder is used as the "formatter" to the Gherkin parser.
          # The builder instance is then returned to the rspec loader.
          parser = Gherkin::Parser::Parser.new(builder, true)
          parser.parse(File.read(test_spec), test_spec, 0)
        end
      end
    end

    attr_reader :specs

    def initialize
      @specs = []
    end

    # Gherkin API Methods

    def uri(*)
    end

    def eof
    end

    def feature(feature)
      @current_feature = Feature.new(feature)
      @specs << @current_feature
    end

    # Test Spec Gherkin Objects

    class Feature
      def initialize(repr)
        @repr = repr
      end

      def name
        @repr.name
      end
    end
  end
end
