require 'lucid/platform'
require 'gherkin/formatter/ansi_escapes'
begin
  # Support Rake > 0.8.7
  require 'rake/dsl_definition'
rescue LoadError
end

# TODO: Determine if this is needed for now.
module Lucid
  module Rake
    # Defines a Rake task for running features.
    #
    # The simplest use of it goes something like:
    #
    #   Lucid::Rake::Task.new
    #
    # This will define a task named <tt>lucid</tt> described as 'Run Lucid features'.
    # It will use steps from 'features/**/*.rb' and features in 'features/**/*.feature'.
    #
    # To further configure the task, you can pass a block:
    #
    #   Lucid::Rake::Task.new do |t|
    #     t.lucid_opts = %w{--format progress}
    #   end
    #
    # See the attributes for additional configuration possibilities.
    class Task
      include Gherkin::Formatter::AnsiEscapes
      include ::Rake::DSL if defined?(::Rake::DSL)

      class InProcessCucumberRunner #:nodoc:
        include ::Rake::DSL if defined?(::Rake::DSL)

        attr_reader :args

        def initialize(libs, lucid_opts, feature_files)
          raise "libs must be an array when running in-process" unless Array === libs
          libs.reverse.each{|lib| $LOAD_PATH.unshift(lib)}
          @args = (
            lucid_opts +
            feature_files
          ).flatten.compact
        end

        def run
          require 'lucid/cli/main'
          failure = Lucid::CLI::App.execute(args)
          raise "Lucid failed" if failure
        end
      end

      class ForkedCucumberRunner #:nodoc:
        include ::Rake::DSL if defined?(::Rake::DSL)

        def initialize(libs, lucid_bin, lucid_opts, bundler, feature_files)
          @libs          = libs
          @lucid_bin     = lucid_bin
          @lucid_opts    = lucid_opts
          @bundler       = bundler
          @feature_files = feature_files
        end

        def load_path(libs)
          ['"%s"' % @libs.join(File::PATH_SEPARATOR)]
        end

        def quoted_binary(lucid_bin)
          ['"%s"' % lucid_bin]
        end

        def use_bundler
          @bundler.nil? ? File.exist?("./Gemfile") && gem_available?("bundler") : @bundler
        end

        def gem_available?(gemname)
          gem_available_new_rubygems?(gemname) || gem_available_old_rubygems?(gemname)
        end

        def gem_available_old_rubygems?(gemname)
          Gem.available?(gemname)
        end

        def gem_available_new_rubygems?(gemname)
          Gem::Specification.respond_to?(:find_all_by_name) && Gem::Specification.find_all_by_name(gemname).any?
        end

        def cmd
          if use_bundler
            [ Lucid::RUBY_BINARY, '-S', 'bundle', 'exec', 'lucid', @lucid_opts,
            @feature_files ].flatten
          else
            [ Lucid::RUBY_BINARY, '-I', load_path(@libs), quoted_binary(@lucid_bin),
            @lucid_opts, @feature_files ].flatten
          end
        end

        def run
          sh cmd.join(" ") do |ok, res|
            if !ok
              exit res.exitstatus
            end
          end
        end
      end

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs

      # Name of the Lucid binary to use for running features. Defaults to Lucid::BINARY
      attr_accessor :binary

      # Extra options to pass to the Lucid binary. Can be overridden by the LUCID_OPTS environment variable.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :lucid_opts
      def lucid_opts=(opts) #:nodoc:
        @lucid_opts = String === opts ? opts.split(' ') : opts
      end

      # Whether or not to fork a new ruby interpreter. Defaults to true. You may gain
      # some startup speed if you set it to false, but this may also cause issues with
      # your load path and gems.
      attr_accessor :fork

      # Define what profile to be used.  When used with lucid_opts it is simply appended
      # to it. Will be ignored when LUCID_OPTS is used.
      attr_accessor :profile

      # Whether or not to run with bundler (bundle exec). Setting this to false may speed
      # up the execution. The default value is true if Bundler is installed and you have
      # a Gemfile, false otherwise.
      #
      # Note that this attribute has no effect if you don't run in forked mode.
      attr_accessor :bundler

      # Define Lucid Rake task
      def initialize(task_name = "lucid", desc = "Run Lucid features")
        @task_name, @desc = task_name, desc
        @fork = true
        @libs = ['lib']
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}
        yield self if block_given?
        @binary = binary.nil? ? Lucid::BINARY : File.expand_path(binary)
        define_task
      end

      def define_task #:nodoc:
        desc @desc
        task @task_name do
          runner.run
        end
      end

      def runner(task_args = nil) #:nodoc:
        lucid_opts = [(ENV['LUCID_OPTS'] ? ENV['LUCID_OPTS'].split(/\s+/) : nil) || lucid_opts_with_profile]
        if(@fork)
          return ForkedCucumberRunner.new(libs, binary, lucid_opts, bundler, feature_files)
        end
        InProcessCucumberRunner.new(libs, lucid_opts, feature_files)
      end

      def lucid_opts_with_profile #:nodoc:
        @profile ? [lucid_opts, '--profile', @profile] : lucid_opts
      end

      def feature_files #:nodoc:
        make_command_line_safe(FileList[ ENV['FEATURE'] || [] ])
      end

      def make_command_line_safe(list)
        list.map{|string| string.gsub(' ', '\ ')}
      end
    end
  end
end
