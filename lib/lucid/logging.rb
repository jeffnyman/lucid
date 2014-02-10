require 'pp'
require 'logger'
require 'stringio'

module Lucid
  class << self
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
  end

  class LucidLogger < Logger
    AST = 6
    VERBOSE = 7
    REPORT = 8
    PROBLEM = 9

    def self.custom_level(tag)
      SEV_LABEL << tag
      sev_index = SEV_LABEL.size - 1

      define_method(tag.downcase.gsub(/\W+/, '_').to_sym) do |progname, &block|
        add(sev_index, nil, progname, &block)
      end
    end

    custom_level 'AST'
    custom_level 'VERBOSE'
    custom_level 'REPORT'
    custom_level 'PROBLEM'
  end

  class LucidLogFormatter < ::Logger::Formatter
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
