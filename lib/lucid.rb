$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'logger'
require 'lucid/platform'
require 'lucid/runtime'
require 'lucid/cli/app'
require 'lucid/step_definitions'
require 'lucid/term/ansicolor'

module Lucid
  class << self
    attr_accessor :wants_to_quit

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
      "\n[ LUCID (#{severity}) ] #{msg}"
    end
  end

end
