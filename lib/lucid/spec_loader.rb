require 'lucid/errors'

module Lucid
  class Runtime
    class SpecLoader
      include Formatter::Duration

      def initialize(spec_files, filters, tag_expression)
        @spec_files, @filters, @tag_expression = spec_files, filters, tag_expression
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
        spec = Lucid::AST::Spec.new

        tag_counts = {}
        start = Time.new
        log.verbose("Specs:\n")

        @spec_files.each do |file|
          spec_file = Lucid::SpecFile.new(file)

          feature = spec_file.parse(@filters, tag_counts)

          if spec_file
            spec.add_feature(feature)
            log.verbose("  * #{file}\n")
          end
        end

        duration = Time.now - start
        log.verbose("Parsing spec files took #{format_duration(duration)}\n\n")

        check_tag_limits(tag_counts)

        @specs = spec
      end

      def check_tag_limits(tag_counts)
        error_messages = []
        @tag_expression.limits.each do |tag_name, tag_limit|
          tag_locations = (tag_counts[tag_name] || [])
          tag_count = tag_locations.length
          if tag_count > tag_limit
            error = "#{tag_name} occurred #{tag_count} times, but the limit was set to #{tag_limit}\n  " +
              tag_locations.join("\n  ")
            error_messages << error
          end
        end
        raise TagExcess.new(error_messages) if error_messages.any?
      end

      def log
        Lucid.logger
      end
    end

  end
end
