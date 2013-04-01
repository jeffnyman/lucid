module Lucid
  class Runtime
    class SpecsLoader

      def initialize(spec_files)
        @spec_files = spec_files
      end

      def specs
        load unless @specs
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

        log.info("Specs:\n")
        @spec_files.each do |f|
          spec_file = SpecFile.new(f)

          # The "spec_file" will contain a Lucid::SpecFile instance, a
          # primary attribute of which will be a @location instance variable.

          spec = spec_file.parse

          # The "spec" will contain an instance of Lucid::AST::Feature.



        end

        @specs = specs
      end

      def log
        Lucid.logger
      end
    end
  end
end