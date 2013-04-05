require "optparse"
require "lucid/cli/profile"

module Lucid
  module CLI
    class Options

      LUCID_FORMATS = {
          'html' => ['Lucid::Formatter::HTML', 'Generates an HTML report.'],
          'standard' => ['Lucid::Formatter::Standard', 'Prints the spec as-is, using color if available.']
      }

      largest = LUCID_FORMATS.keys.map { |s| s.length }.max
      FORMAT_LIST = LUCID_FORMATS.keys.sort.map do |key|
        "  #{key}#{' ' * (largest - key.length)} : #{LUCID_FORMATS[key][1]}"
      end

      def initialize(out_stream = STDOUT, err_stream = STDERR, options = {})
        @out_stream = out_stream
        @err_stream = err_stream
        @options = default_options
        @profiles = []
        @default_profile = options[:default_profile]
      end

      def [](key)
        @options[key]
      end

      def []=(key, value)
        @options[key] = value
      end

      def parse(args)
        @args = args

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Lucid: Test Description Language Execution Engine",
                         "Usage: lucid [options]"].join("\n")

          opts.on("--library-path PATH", "Location of spec project library files.") do |path|
            @options[:library_path] = path
          end

          opts.on("--spec-type TYPE", "The file type (extension) for Lucid specifications.") do |type|
            @options[:spec_type] = type
          end

          opts.on("-e", "--exclude PATTERN", "Lucid will not use files that match the PATTERN.") do |pattern|
            @options[:excludes] << Regexp.new(pattern)
          end

          opts.separator ''

          opts.on("-t TAGS", "--tags TAGS",
                  "Lucid will only execute features or scenarios with tags that match the",
                  "tag expression provided. A single tag expressions can have several tags",
                  "separated by a comma, which represents a logical OR. If this option is",
                  "provided more than once, this represents a logical AND. A tag expression",
                  "can be prefaced with a ~ character, which represents a logical NOT."
          ) do |tags|
            @options[:tags] << tags
          end

          opts.on("-n NAME", "--name NAME",
                  "Lucid will only execute features or abilities that match with the name",
                  "provided. The match can be done on partial information. If this option",
                  "is provided multiple times, then the match will be performed against",
                  "each set of provided names."
          ) do |name|
            @options[:names] << /#{name}/
          end

          opts.on("-f FORMAT", "--format FORMAT", "How Lucid will format spec execution output.",
                  "(Default: standard) Available formats:",
                  *FORMAT_LIST
          ) do |format|
            @options[:formats] << [format, @out_stream]
          end

          opts.on("-o", "--out [FILE|DIR]",
                  "Write output to a file or directory instead of to standard console output.",
                  "This option applies to any specified format option or to the default",
                  "format if no formatter is specified."
          ) do |output|
            @options[:formats] << ['standard', nil] if @options[:formats].empty?
            @options[:formats][-1][1] = output
          end

          opts.separator ''

          opts.on("--verbose", "Show detailed information about Lucid execution.") do
            @options[:verbose] = true
          end

          opts.on("--debug", "Show behind-the-scenes information about Lucid execution.") do
            @options[:debug] = true
          end

          opts.separator ''

          opts.on_tail("--version", "Show Lucid version information.") do
            @out_stream.puts Lucid::VERSION
            Kernel.exit(0)
          end

          opts.on_tail("-h", "--help", "Show Lucid execution information.") do
            @out_stream.puts opts.help
            Kernel.exit(0)
          end
        end.parse!

        # This line grabs whatever is left over on the command line. That
        # would have to be the spec repo
        @options[:spec_source] = @args.dup

        establish_profile
        indicate_profile

        self
      end

      # @see Lucid::CLI::Configuration.filters
      def filters
        @options.values_at(:names, :tags).select { |v| !v.empty? }.first || []
      end

    private

      def default_options
        {
          :spec_type => "",
          :library_path => "",
          :excludes => [],
          :formats => [],
          :names => [],
          :tags => []
        }
      end

      def establish_profile
        @profiles << @default_profile if using_default_profile?

        #puts("***** In establish_profile, @profiles is #{@profiles.inspect}")
        #puts("***** In establish_profile, @default_profile is #{@default_profile.inspect}")

        @profiles.each do |profile|
          puts("***** #{profile} from #{@profiles.inspect}")
        end
      end

      def indicate_profile
        return if @profiles.empty?
      end

      def using_default_profile?
        # It may not be obvious what this is doing. The check here is for if
        # the profiles are empty and there is a lucid file. If so, then check
        # if the file has a profile called default. If it does, that will be
        # as if a default profile was used.
        @profiles.empty? &&
          profile_loader.lucid_yml_defined? &&
          profile_loader.has_profile?(@default_profile)
      end

      def profile_loader
        @profile ||= Profile.new
      end

    end
  end
end