require 'lucid/platform'
require 'gherkin/formatter/ansi_escapes'
begin
  require 'rake/dsl_definition'
rescue LoadError
end

module Lucid
  module Rake
    # Defines a Rake task for running specs.
    #
    # The simplest use of it goes something like:
    #
    #   Lucid::Rake::Task.new
    #
    # This will define a task named <tt>lucid</tt> described as 'Run Lucid specs'.
    # It will use steps from 'specs/**/*.rb' and features in 'specs/**/*.spec'.
    #
    # To further configure the task, you can pass a block:
    #
    #   Lucid::Rake::Task.new do |t|
    #     t.lucid_opts = %w{--format progress}
    #   end
    #
    # This task can also be configured to be run with RCov:
    #
    #   Lucid::Rake::Task.new do |t|
    #     t.rcov = true
    #   end
    #
    # See the attributes for additional configuration possibilities.
    class Task
      include Gherkin::Formatter::AnsiEscapes
      include ::Rake::DSL if defined?(::Rake::DSL)

      class InProcessLucidRunner #:nodoc:
        include ::Rake::DSL if defined?(::Rake::DSL)

        attr_reader :args

        def initialize(libs, lucid_opts, feature_files)
          raise 'libs must be an Array when running in-process' unless Array === libs
          libs.reverse.each{|lib| $LOAD_PATH.unshift(lib)}
          @args = (
          lucid_opts +
              feature_files
          ).flatten.compact
        end

        def run
          require 'lucid/cli/app'
          failure = Lucid::CLI::App.start(args)
          raise 'Lucid failed' if failure
        end
      end

      class ForkedLucidRunner #:nodoc:
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
          @bundler.nil? ? File.exist?('./Gemfile') && bundler_gem_available? : @bundler
        end

        def bundler_gem_available?
          Gem::Specification.find_by_name('bundler')
        rescue Gem::LoadError
          false
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
          sh cmd.join(' ') do |ok, res|
            if !ok
              exit res.exitstatus
            end
          end
        end
      end

      class RCovLucidRunner < ForkedLucidRunner #:nodoc:

        def initialize(libs, lucid_bin, lucid_opts, bundler, feature_files, rcov_opts)
          super(       libs, lucid_bin, lucid_opts, bundler, feature_files )
          @rcov_opts = rcov_opts
        end

        def cmd
          if use_bundler
            [Lucid::RUBY_BINARY, '-S', 'bundle', 'exec', 'rcov', @rcov_opts,
             quoted_binary(@lucid_bin), '--', @lucid_opts, @feature_files].flatten
          else
            [Lucid::RUBY_BINARY, '-I', load_path(@libs), '-S', 'rcov', @rcov_opts,
             quoted_binary(@lucid_bin), '--', @lucid_opts, @feature_files].flatten
          end
        end

      end

      LIB = File.expand_path(File.dirname(__FILE__) + '/../..') #:nodoc:

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs

      # Name of the lucid binary to use for running features. Defaults to Lucid::BINARY
      attr_accessor :binary

      # Extra options to pass to the lucid binary. Can be overridden by the LUCID_OPTS environment variable.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :lucid_opts
      def lucid_opts=(opts) #:nodoc:
        @lucid_opts = String === opts ? opts.split(' ') : opts
      end

      # Run lucid with RCov? Defaults to false. If you set this to
      # true, +fork+ is implicit.
      attr_accessor :rcov
      def rcov=(flag)
        if flag && !Lucid::RUBY_1_8_7
          raise failed + 'RCov only works on Ruby 1.8.x. You may want to use SimpleCov.' + reset
        end
        @rcov = flag
      end

      # Extra options to pass to rcov.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :rcov_opts
      def rcov_opts=(opts) #:nodoc:
        @rcov_opts = String === opts ? opts.split(' ') : opts
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
      def initialize(task_name = 'lucid', desc = 'Run Lucid specs')
        @task_name, @desc = task_name, desc
        @fork = true
        @libs = ['lib']
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @binary = binary.nil? ? Lucid::BINARY : File.expand_path(binary)
        @libs.insert(0, LIB) if binary == Lucid::BINARY

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
        if(@rcov)
          RCovLucidRunner.new(libs, binary, lucid_opts, bundler, feature_files, rcov_opts)
        elsif(@fork)
          ForkedLucidRunner.new(libs, binary, lucid_opts, bundler, feature_files)
        else
          InProcessLucidRunner.new(libs, lucid_opts, feature_files)
        end
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
