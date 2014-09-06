require 'lucid/version'
require 'lucid/builder'
require 'lucid/runner'
require 'lucid/errors'
require 'lucid/table'

module Lucid
  def self.version
    "Lucid v#{Lucid::VERSION}"
  end
end
