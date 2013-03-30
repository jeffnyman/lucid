require "logger"
require "lucid/version"

module Lucid

  class << self

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
      puts "\n[ LUCID (#{severity}) ] #{msg}"
    end
  end

end
