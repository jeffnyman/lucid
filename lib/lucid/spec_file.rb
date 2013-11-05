require 'lucid/tdl_builder'
require 'gherkin/formatter/filter_formatter'
require 'gherkin/formatter/tag_count_formatter'
require 'gherkin/parser/parser'

module Lucid
  class SpecFile
    SPEC_PATTERN     = /^([\w\W]*?):([\d:]+)$/ #:nodoc:
    DEFAULT_ENCODING = 'UTF-8' #:nodoc:
    NON_EXEC_PATTERN = /^\s*#|^\s*$/ #:nodoc:
    ENCODING_PATTERN = /^\s*#\s*encoding\s*:\s*([^\s]+)/ #:nodoc:

    # The +uri+ argument is the location of the source. It can be a path
    # or a path:line1:line2 etc.
    def initialize(uri, source=nil)
      @source = source
      _, @path, @lines = *SPEC_PATTERN.match(uri)
      if @path
        @lines = @lines.split(':').map { |line| line.to_i }
      else
        @path = uri
      end
    end

    # The parse action will parse a specific spec source and will return
    # a the high level construct of the spec. If any filters are passed
    # in, the result will be filtered accordingly.
    # @see Lucid::Runtime::SpecsLoader.load
    def parse(specified_filters, tag_counts)
      filters = @lines || specified_filters

      tdl_builder         = Lucid::Parser::TDLBuilder.new(@path)
      filter_formatter    = filters.empty? ? tdl_builder : Gherkin::Formatter::FilterFormatter.new(tdl_builder, filters)
      tag_count_formatter = Gherkin::Formatter::TagCountFormatter.new(filter_formatter, tag_counts)

      # Gherkin Parser parameters:
      # formatter, raise_on_error, machine_name, force_ruby
      # The machine name refers to a state machine table.
      parser              = Gherkin::Parser::Parser.new(tag_count_formatter, true, "root", false)

      begin
        # parse parameters:
        # gherkin, feature_uri, line_offset
        parser.parse(source, @path, 0)
        tdl_builder.language = parser.i18n_language
        tdl_builder.result
      rescue Gherkin::Lexer::LexingError, Gherkin::Parser::ParseError => e
        e.message.insert(0, "#{@path}: ")
        raise e
      end
    end

    # The source method is used to return a properly encoded spec file.
    # If the spec source read in declares a different encoding, then this
    # method will make sure to use Lucid's default encoding.
    def source
      @source ||= if @path =~ /^http/
        require 'open-uri'
        open(@path).read
      else
        begin
          source = File.open(@path, Lucid.file_mode('r', DEFAULT_ENCODING)).read
          encoding = encoding_for(source)
          if(DEFAULT_ENCODING.downcase != encoding.downcase)
            source = File.open(@path, Lucid.file_mode('r', encoding)).read
            source = to_default_encoding(source, encoding)
          end
          source
        rescue Errno::EACCES => e
          e.message << "\nLucid was unable to access #{File.expand_path(@path)}."
          raise e
        rescue Errno::ENOENT => e
          if @path == "specs"
            STDOUT.puts ["\nYou don't have a 'specs' directory. This is the default specification",
                         "directory that Lucid will use if one is not specified. So either create",
                         "that directory or specify where your test repository is located.\n\n"].join("\n")
          else
            STDOUT.puts ["\nThere is no '#{@path}' directory. Since that is what you specified as",
                         "your spec repository, this directory must be present."].join("\n")
          end
          Kernel.exit(1)
        end
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
