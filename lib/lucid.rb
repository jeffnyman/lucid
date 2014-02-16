$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pp'
require 'yaml'
require 'logger'
require 'stringio'
require 'lucid/platform'
require 'lucid/context_loader'
require 'lucid/cli/app'
require 'lucid/step_definitions'
require 'lucid/ansicolor'

module Lucid
  class << self
    attr_accessor :wants_to_quit

    def breakdown(*args)
      current_output = $stdout
      begin
        msg_string = StringIO.new
        $stdout = msg_string
        pp(*args)
      ensure
        $stdout = current_output
      end
      msg_string.string
    end

    def logger
      return @log if @log
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
      @log
    end

    def logger=(logger)
      @log = logger
    end
  end

  class LogFormatter < ::Logger::Formatter
    def call(severity, time, progname, msg)
      if msg.is_a?(String)
        "\n[ LUCID (#{severity}) ] #{msg}\n"
      else
        msg = Lucid.breakdown(msg)
        "\n[ LUCID (#{severity}) ] \n#{msg}\n"
      end
    end
  end

end
