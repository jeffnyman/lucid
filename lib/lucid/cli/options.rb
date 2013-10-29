require 'lucid/cli/profile'
require 'lucid/formatter/ansicolor'
require 'lucid/interface_rb/rb_language'

module Lucid
  module CLI
    class Options

      INDENT = ' ' * 53
      LUCID_FORMATS = {
        'html'        => ['Lucid::Formatter::Html',        'Generates an HTML report.'],
        'standard'    => ['Lucid::Formatter::Standard',    'Prints the spec as-is, using color if available.'],
        'condensed'   => ['Lucid::Formatter::Condensed',   'Output only spec file and scenarios.'],
        'progress'    => ['Lucid::Formatter::Progress',    'Prints one character per scenario.'],
        'rerun'       => ['Lucid::Formatter::Rerun',       'Prints failing specs with line numbers.'],
        'usage'       => ['Lucid::Formatter::Usage',       "Prints where test definitions are used.\n" +
                                                              "#{INDENT}The slowest test definitions (with duration) are\n" +
                                                              "#{INDENT}listed first. If --dry-run is used the duration\n" +
                                                              "#{INDENT}is not shown, and test definitions are sorted by\n" +
                                                              "#{INDENT}file name instead."],
        'testdefs'    => ['Lucid::Formatter::Testdefs',    "Prints all test definitions with their locations. Same as\n" +
                                                              "#{INDENT}the usage formatter, except that steps are not printed."],
        'junit'       => ['Lucid::Formatter::Junit',       'Generates a report similar to Ant+JUnit.'],
        'json'        => ['Lucid::Formatter::Json',        'Prints the spec as JSON.'],
        'json_pretty' => ['Lucid::Formatter::JsonPretty',  'Prints the spec as prettified JSON.'],
        'debug'       => ['Lucid::Formatter::Debug',       'Prints the calls made to the listeners.']
      }
      largest = LUCID_FORMATS.keys.map{|s| s.length}.max
      FORMAT_LIST = (LUCID_FORMATS.keys.sort.map do |key|
        "  #{key}#{' ' * (largest - key.length)} : #{LUCID_FORMATS[key][1]}"
      end) + ['Use --format rerun --out rerun.txt to write out failing',
              'specs. You can rerun them with lucid @rerun.txt.',
              'FORMAT can also be the fully qualified class name of',
              "your own custom formatter. If the class isn't loaded,",
              'Lucid will attempt to require a file with a relative',
              'file name that is the underscore name of the class name.',
              '  Example: --format Formatter::WordDoc',
              'With that, Lucid will look for formatter/word_doc.rb',
              'You can place the file with this relative path',
              'underneath your common/support directory or anywhere',
              "on Ruby's LOAD_PATH."
      ]
      PROFILE_SHORT_FLAG = '-p'
      NO_PROFILE_SHORT_FLAG = '-P'
      PROFILE_LONG_FLAG = '--profile'
      NO_PROFILE_LONG_FLAG = '--no-profile'
      OPTIONS_WITH_ARGS = ['-r', '--require', '--i18n', '-f', '--format', '-o', '--out',
                           '-t', '--tags', '-n', '--name', '-e', '--exclude',
                           PROFILE_SHORT_FLAG, PROFILE_LONG_FLAG,
                           '--lines', '--port',
                           '-I', '--matcher-type']

      def self.parse(args, out_stream, error_stream, options = {})
        new(out_stream, error_stream, options).parse(args)
      end

      def initialize(out_stream = STDOUT, error_stream = STDERR, options = {})
        @out_stream   = out_stream
        @error_stream = error_stream

        @default_profile = options[:default_profile]
        @profiles = []
        @overridden_paths = []
        @options = default_options
        @profile_loader = options[:profile_loader]
        @options[:skip_profile_information] = options[:skip_profile_information]

        @quiet = @disable_profile_loading = nil
      end

      def [](key)
        @options[key]
      end

      def []=(key, value)
        @options[key] = value
      end

      def parse(args)
        @args = args
        @expanded_args = @args.dup

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ['Lucid: Test Description Language Execution Engine',
                         'Usage: lucid [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]+', '', ''
          ].join("\n")

          opts.on('--library-path PATH', 'Location of spec project library files.') do |path|
            @options[:library_path] = path
          end

          opts.on('--spec-type TYPE', 'The file type (extension) for Lucid specifications.') do |type|
            #@options[:spec_type] = type
            @options[:spec_type] << type
          end

          opts.on('--driver-file FILE', 'The file for Lucid to connect to an execution library.') do |file|
            @options[:driver_file] = file
          end

          opts.separator ''

          opts.on('-r LIBRARY|DIR', '--require LIBRARY|DIR',
                  'Require files before executing the features. If this option',
                  'is not specified, all *.rb files that are siblings or below',
                  'the features will be loaded automatically. Automatic loading',
                  'is disabled when this option is specified. That means all',
                  'loading becomes explicit.',
                  'Assuming a default specs repo configuration, files under',
                  "directories named \"common\\support\" will always be loaded",
                  'before any others.',
                  'This option can be specified multiple times.') do |v|
            @options[:require] << v
            if(Lucid::JRUBY && File.directory?(v))
              require 'java'
              $CLASSPATH << v
            end
          end

          opts.separator ''

          opts.on('-f FORMAT', '--format FORMAT',
                  'How Lucid will format spec execution output.',
                  '(Default: standard). Available formats:',
                  *FORMAT_LIST
          ) do |v|
            @options[:formats] << [v, @out_stream]
          end

          opts.on('-o', '--out [FILE|DIR]',
                  'Write output to a file or directory instead of to standard',
                  'console output. This option applies to any specified format',
                  'option (via the --format switch) or to the default format',
                  'if no format was specified. You can check the specific',
                  'documentation for a given formatter to see whether to pass',
                  'a file or a directory.'
          ) do |v|
            @options[:formats] << ['standard', nil] if @options[:formats].empty?
            @options[:formats][-1][1] = v
          end

          opts.separator ''

          opts.on('-d', '--dry-run', 'Invokes formatters without executing the steps.',
                  'This also omits the loading of your common/support/driver.rb file if it exists.') do
            @options[:dry_run] = true
          end

          opts.on('-n NAME', '--name NAME',
                  'Lucid will only execute features or abilities that match with the name',
                  'provided. The match can be done on partial information. If this option',
                  'is provided multiple times, then the match will be performed against',
                  'each set of provided names.'
          ) do |v|
            @options[:name_regexps] << /#{v}/
          end

          opts.on('-l', '--lines LINES', 'Run given line numbers. Equivalent to FILE:LINE syntax') do |lines|
            @options[:lines] = lines
          end

          opts.on('-e', '--exclude PATTERN',
                  'Lucid will not use files that match the PATTERN.') do |v|
            @options[:excludes] << Regexp.new(v)
          end

          opts.on('-t TAG_EXPRESSION', '--tags TAG_EXPRESSION',
                  'Lucid will only execute features or scenarios with tags that match the',
                  'tag expression provided. A single tag expressions can have several tags',
                  'separated by a comma, which represents a logical OR. If this option is',
                  'provided more than once, this represents a logical AND. A tag expression',
                  'can be prefaced with a ~ character, which represents a logical NOT.',
                  'Examples:',
                  ' --tags @smoke.',
                  ' --tags ~@wip',
                  ' --tags @smoke,@wip',
                  ' --tags @smoke,~@wip --tags @regression',
                  'If you want to use multiple exclusion tags, you must use the logical',
                  'AND approach, as in: --tags ~@wip --tags ~@failing',
                  'Positive tags can be given a threshold to limit the number of occurrences.',
                  'Example: --tags @critical:3',
                  'That will fail if there are more than three occurrences of the @critical tag.'
          ) do |v|
            @options[:tag_expressions] << v
          end

          opts.separator ''

          opts.on(PROFILE_SHORT_FLAG, "#{PROFILE_LONG_FLAG} PROFILE",
                  'Pull commandline arguments from lucid.yml which can be defined as',
                  'strings or arrays. When a default profile is defined and no profile',
                  'is specified it is always used. (Unless disabled, see -P below.)',
                  'When feature files are defined in a profile and on the command line',
                  'then only the ones from the command line are used.'
          ) do |v|
            @profiles << v
          end

          opts.on(NO_PROFILE_SHORT_FLAG, NO_PROFILE_LONG_FLAG,
            'Disables all profile loading to avoid using the default profile.') do |v|
            @disable_profile_loading = true
          end

          opts.separator ''

          opts.on('-c', '--[no-]color',
                  'Specifies whether or not to use ANSI color in the output. If this',
                  'option is not specified, Lucid makes the decision on colored output',
                  'based on your platform and the output destination.'
          ) do |v|
            Lucid::Term::ANSIColor.coloring = v
          end

          opts.on('-m', '--no-multiline',
                  'Lucid will not print multiline strings and tables under steps.') do
            @options[:no_multiline] = true
          end

          opts.on('-s', '--no-source',
                  'Lucid will not print the file and line of the test definition with the steps.') do
            @options[:source] = false
          end

          opts.on('-i', '--no-matchers',
                  'Lucid will not print matchers for pending steps.') do
            @options[:matchers] = false
          end

          opts.on('-I', '--matchers-type TYPE',
                  'Use different matcher type (Default: regexp).',
                  'Available types:',
                  *Lucid::InterfaceRb::RbLanguage.cli_matcher_type_options
          ) do |v|
            @options[:matcher_type] = v.to_sym
          end

          opts.on('-q', '--quiet', 'Alias for --no-matchers --no-source.') do
            @quiet = true
          end

          opts.on('-S', '--strict', 'Fail if there are any undefined or pending steps.') do
            @options[:strict] = true
          end

          opts.on('-w', '--wip', 'Fail if there are any passing scenarios.') do
            @options[:wip] = true
          end

          opts.on('-g', '--guess', 'Guess best match for ambiguous steps.') do
            @options[:guess] = true
          end

          opts.on('-x', '--expand', 'Expand Scenario Outline tables in output.') do
            @options[:expand] = true
          end

          opts.separator ''

          opts.on('--testdefs DIR', 'Lucid will write test definition metadata to the DIR.') do |dir|
            @options[:testdefs] = dir
          end

          if(Lucid::JRUBY)
            opts.on('-j DIR', '--jars DIR',
                    'Load all the jars under the specified directory.') do |jars|
              Dir["#{jars}/**/*.jar"].each {|jar| require jar}
            end
          end

          opts.on('--i18n LANG',
                  'List keywords for a particular language.',
                  'Run with "--i18n help" to see all languages') do |lang|
            if lang == 'help'
              list_languages_and_exit
            else
              list_keywords_and_exit(lang)
            end
          end

          opts.separator ''

          opts.on('-b', '--backtrace', 'Show full backtrace for all errors during Lucid execution.') do
            Lucid.use_full_backtrace = true
          end

          opts.on('-v', '--verbose', 'Show detailed information about Lucid execution.') do
            @options[:verbose] = true
          end

          opts.on('--debug', 'Show behind-the-scenes information about Lucid execution.') do
            @options[:debug] = true
          end

          opts.separator ''

          opts.on_tail('--version', 'Show Lucid version information.') do
            @out_stream.puts Lucid::VERSION
            Kernel.exit(0)
          end

          opts.on_tail('-h', '--help', 'Show Lucid execution options.') do
            @out_stream.puts opts.help
            Kernel.exit(0)
          end
        end
        #end.parse!

        begin
          @args.parse!
        rescue OptionParser::InvalidOption
          if $!.to_s =~ /invalid option\:\s+((?:-)?-\S+)/
            puts "You specified an invalid option: #{$1}"
            puts 'Please run lucid --help to see the list of available options.'
          end

        rescue OptionParser::MissingArgument
          if $!.to_s =~ /missing argument\:\s+((?:-)?-\S+)/
            puts "You specified an valid option (#{$1}), but with an invalid argument."
            puts 'Make sure you are providing the expected argument for the option.'
            puts 'Run lucid --help to see the list of available options.'
          end

          Kernel.exit(1)
        end

        if @quiet
          @options[:matchers] = @options[:source] = false
        else
          @options[:matchers] = true if @options[:matchers].nil?
          @options[:source]   = true if @options[:source].nil?
        end
        @args.map! { |a| "#{a}:#{@options[:lines]}" } if @options[:lines]

        extract_environment_variables

        # This line grabs whatever is left over on the command line. That
        # would have to be the spec repo.
        @options[:spec_source] = @args.dup

        establish_profile

        self
      end

      def custom_profiles
        @profiles - [@default_profile]
      end

      # @see Lucid::CLI::Configuration.filters
      def filters
        @options.values_at(:name_regexps, :tag_expressions).select{|v| !v.empty?}.first || []
      end

    protected

      attr_reader :options, :profiles, :expanded_args
      protected :options, :profiles, :expanded_args

    private

      def non_stdout_formats
        @options[:formats].select {|format, output| output != @out_stream }
      end

      def stdout_formats
        @options[:formats].select {|format, output| output == @out_stream }
      end

      def extract_environment_variables
        @args.delete_if do |arg|
          if arg =~ /^(\w+)=(.*)$/
            @options[:env_vars][$1] = $2
            true
          end
        end
      end

      def disable_profile_loading?
        @disable_profile_loading
      end

      def establish_profile
        if @disable_profile_loading
          @out_stream.puts 'Disabling profiles...'
          return
        end

        @profiles << @default_profile if using_default_profile?

        @profiles.each do |profile|
          merge_with_profile(profile)
        end

        @options[:profiles] = @profiles
      end

      def merge_with_profile(profile)
        profile_args = profile_loader.args_from(profile)
        profile_options = Options.parse(
          profile_args, @out_stream, @error_stream,
          :skip_profile_information => true,
          :profile_loader => profile_loader
        )
        reverse_merge(profile_options)
      end

      def using_default_profile?
        @profiles.empty? &&
          profile_loader.lucid_yml_defined? &&
          profile_loader.has_profile?(@default_profile)
      end

      def profile_loader
        @profile_loader ||= Profile.new
      end

      def reverse_merge(other_options)
        @options = other_options.options.merge(@options)
        @options[:require] += other_options[:require]

        @options[:excludes] += other_options[:excludes]
        @options[:name_regexps] += other_options[:name_regexps]
        @options[:tag_expressions] += other_options[:tag_expressions]
        @options[:env_vars] = other_options[:env_vars].merge(@options[:env_vars])
        if @options[:spec_source].empty?
          @options[:spec_source] = other_options[:spec_source]
        else
          @overridden_paths += (other_options[:spec_source] - @options[:spec_source])
        end
        @options[:source] &= other_options[:source]
        @options[:matchers] &= other_options[:matchers]
        @options[:strict] |= other_options[:strict]
        @options[:dry_run] |= other_options[:dry_run]

        @options[:library_path] += other_options[:library_path]
        @options[:spec_type] += other_options[:spec_type]
        @options[:driver_file] += other_options[:driver_file]

        @profiles += other_options.profiles
        @expanded_args += other_options.expanded_args

        if @options[:formats].empty?
          @options[:formats] = other_options[:formats]
        else
          @options[:formats] += other_options[:formats]
          @options[:formats] = stdout_formats[0..0] + non_stdout_formats
        end

        self
      end

      def list_keywords_and_exit(lang)
        require 'gherkin/i18n'
        @out_stream.write(Gherkin::I18n.get(lang).keyword_table)
        Kernel.exit(0)
      end

      def list_languages_and_exit
        require 'gherkin/i18n'
        @out_stream.write(Gherkin::I18n.language_table)
        Kernel.exit(0)
      end

      def default_options
        {
          :strict           => false,
          :require          => [],
          :dry_run          => false,
          :formats          => [],
          :excludes         => [],
          :tag_expressions  => [],
          :name_regexps     => [],
          :env_vars         => {},
          :diff_enabled     => true,
          :spec_type        => %w(feature spec),
          :library_path     => '',
          :driver_file      => ''
        }
      end
    end

  end
end
