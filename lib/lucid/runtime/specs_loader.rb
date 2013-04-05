require "lucid/formatter/duration"

module Lucid
  class Runtime
    class SpecsLoader
      include Formatter::Duration

      def initialize(spec_files, filters, tags)
        @spec_files = spec_files
        @filters = filters
        @tags = tags
      end

      # @see Lucid::Runtime.specs
      def specs
        load unless (defined? @specs) and @specs
        @specs
      end

    private

      # The specs loader will call upon load to load up all specs that were
      # found in the spec repository. During this process, a Specs instance
      # is created that will hold instances of the high level construct,
      # which is basically the feature.
      def load
        specs = AST::Specs.new

        # Note that "specs" is going to be an instance of Lucid::AST::Specs.
        # It will contain a @specs instance variable that is going to contain
        # an specs found.

        tag_counts = {}
        start = Time.new
        log.info("Specs:\n")
        @spec_files.each do |f|
          spec_file = SpecFile.new(f)

          # The "spec_file" will contain a Lucid::SpecFile instance, a
          # primary attribute of which will be a @location instance variable.

          spec = spec_file.parse(@filters, tag_counts)

          # The "spec" will contain an instance of Lucid::AST::Feature.



        end
        duration = Time.now - start
        log.info("Parsing spec files took #{format_duration(duration)}\n\n")

        @specs = specs
      end

      def log
        Lucid.logger
      end
    end
  end
end