require 'autotest'
require 'tempfile'
require 'lucid'
require 'lucid/cli/profile'

module Autotest::LucidMixin
  def self.included(receiver)
    receiver::ALL_HOOKS << [:run_specs, :ran_specs]
  end

  attr_accessor :specs_to_run

  def initialize
    super
    reset_specs
  end

  def run
    hook :initialize
    reset
    reset_specs
    add_sigint_handler

    self.last_mtime = Time.now if $f

    loop do
      begin
        get_to_green
        if self.tainted then
          rerun_all_tests
          rerun_all_specs if all_good
        else
          hook :all_good
        end
        wait_for_changes
        # Once tests and specs are running green, this should reset specs
        # every time a file is changed to see if anything breaks.
        reset_specs
      rescue Interrupt
        break if self.wants_to_quit
        reset
        reset_specs
      end
    end
    hook :quit
  end

  def all_specs_good
    specs_to_run == ""
  end

  def get_to_green
    begin
      super
      run_specs
      wait_for_changes unless all_specs_good
    end until all_specs_good
  end

  def rerun_all_specs
    reset_specs
    run_specs
  end

  def reset_specs
    self.specs_to_run = :all
  end

  def run_specs
    hook :run_specs
    Tempfile.open('autotest-lucid') do |dirty_specs_file|
      cmd = self.make_lucid_cmd(self.specs_to_run, dirty_specs_file.path)
      return if cmd.empty?
      puts cmd unless $q
      old_sync = $stdout.sync
      $stdout.sync = true
      self.results = []
      line = []
      begin
        open("| #{cmd}", "r") do |f|
          until f.eof? do
            c = f.getc or break
            if RUBY_VERSION >= "1.9" then
              print c
            else
              putc c
            end
            line << c
            if c == ?\n then
              self.results << if RUBY_VERSION >= "1.9" then
                                line.join
                              else
                                line.pack "c*"
                              end
              line.clear
            end
          end
        end
      ensure
        $stdout.sync = old_sync
      end
      self.specs_to_run = dirty_specs_file.read.strip
      self.tainted = true unless self.specs_to_run == ''
    end
    hook :ran_specs
  end

  def make_lucid_cmd(specs_to_run, dirty_specs_filename)
    return '' if specs_to_run == ''

    profile_loader = Lucid::CLI::Profile.new

    profile ||= "autotest-all" if profile_loader.has_profile?("autotest-all") && specs_to_run == :all
    profile ||= "autotest"     if profile_loader.has_profile?("autotest")
    profile ||= nil

    if profile
      args = ["--profile", profile]
    else
      args = %w{--format} << (specs_to_run == :all ? "progress" : "standard")
    end
    # No --color option as some IDEs (Netbeans) don't output them very well ([31m1 failed step[0m)
    args += %w{--format rerun --out} << dirty_specs_filename
    args << (specs_to_run == :all ? "" : specs_to_run)

    unless specs_to_run == :all
      args << 'steps' << 'common'
    end

    args = args.join(' ')

    return "#{Lucid::RUBY_BINARY} #{Lucid::BINARY} #{args}"
  end
end
