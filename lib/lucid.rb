$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'lucid/platform'
require 'lucid/parser'
require 'lucid/runtime'
require 'lucid/cli/main'
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
end
