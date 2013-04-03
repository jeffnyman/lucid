require "lucid/tdl_builder"
require "gherkin/parser/parser"

module Lucid
  class SpecFile

    SPEC_PATTERN = /^([\w\W]*?):([\d:]+)$/
    NON_EXEC_PATTERN = /^\s*#|^\s*$/
    DEFAULT_ENCODING = "UTF-8"
    ENCODING_PATTERN = /^\s*#\s*encoding\s*:\s*([^\s]+)/

    # The uri argument is the location of the source.
    def initialize(uri)
      root, @path, @lines = *SPEC_PATTERN.match(uri)
      if @path
        @lines = @lines.split(':').map { |line| line.to_i }
      else
        @path = uri
      end
    end

    # The parse action will parse a specific spec source and will return
    # a the high level construct of the spec.
    def parse
      tdl_builder = Lucid::Parser::TDLBuilder.new(@path)

      # Gherkin Parser parameters:
      # formatter, raise_on_error, machine_name, force_ruby
      # The machine name refers to a state machine table.
      parser = Gherkin::Parser::Parser.new(tdl_builder, true, "root", false)

      begin
        # parse parameters:
        # gherkin, feature_uri, line_offset
        parser.parse(source, @path, 0)
      end
    end

    # The source method is used to return a properly encoded spec file.
    # If the spec source read in declares a different encoding, then this
    # method will make sure to use Lucid's default encoding.
    def source
      begin
        source = File.open(@path, "r:#{DEFAULT_ENCODING}").read
        encoding = encoding_for(source)
        if(DEFAULT_ENCODING.downcase != encoding.downcase)
          source = File.open(@path, "r:#{DEFAULT_ENCODING}").read
          source = to_default_encoding(source, encoding)
        end
        source
      rescue Errno::EACCES => e
        e.message << "\nLucid was unable to open #{File.expand_path(@path)}"
        raise e
      rescue Errno::ENOENT => e
        if(@path == 'specs')
          STDERR.puts("You don't have a 'specs' directory.  This is the default specification",
                      "directory that Lucid will use if one is not specified. So either create",
                      "that directory or specify where your test repository is located.")
          exit 1
        end
        raise e
      end
    end

  private

    def encoding_for(source)
      encoding = DEFAULT_ENCODING
      source.each_line do |line|
        break unless NON_EXEC_PATTERN =~ line
        if ENCODING_PATTERN =~ line
          encoding = $1
          break
        end
      end
      encoding
    end

    def to_default_encoding(string, encoding)
      if string.respond_to?(:encode)
        string.encode(DEFAULT_ENCODING)
      else
        require 'iconv'
        Iconv.new(DEFAULT_ENCODING, encoding).iconv(string)
      end
    end

  end
end