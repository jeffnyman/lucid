require "lucid/tdl_builder"

module Lucid
  class SpecFile

    def initialize(uri)

    end

    # The parse action will parse a specific spec source and will return
    # a the high level construct of the spec.
    def parse
      tdl_builder = Lucid::Parser::TDLBuilder.new
    end

  end
end