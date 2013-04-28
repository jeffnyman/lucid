# Require this file if you need Unicode support.
# Tips for improvement - esp. ruby 1.9: http://www.ruby-forum.com/topic/184730
require 'lucid/platform'
require 'lucid/formatter/ansicolor'

if Lucid::WINDOWS
  if ENV['LUCID_OUTPUT_ENCODING']
    Lucid::CODEPAGE = ENV['LUCID_OUTPUT_ENCODING']
  elsif `cmd /c chcp` =~ /(\d+)/
    if [65000, 65001].include? $1.to_i
      Lucid::CODEPAGE = 'UTF-8'
      ENV['ANSICON_API'] = 'ruby'
    else
      Lucid::CODEPAGE = "cp#{$1.to_i}"
    end
  else
    Lucid::CODEPAGE = "cp1252"
    STDERR.puts("WARNING: Unable to detect your output codepage; assuming it is 1252. You may have to chcp 1252 or SET LUCID_OUTPUT_ENCODING=cp1252.")
  end

  module Lucid
    # @private
    module WindowsOutput
      def self.extended(o)
        o.instance_eval do

          def lucid_preprocess_output(*a)
            begin
              a.map{|arg| arg.to_s.encode(Encoding.default_external)}
            rescue Encoding::UndefinedConversionError => e
              STDERR.lucid_puts("WARNING: #{e.message}")
              a
            end
          end

          alias lucid_print print
          def print(*a)
            lucid_print(*lucid_preprocess_output(*a))
          end

          alias lucid_puts puts
          def puts(*a)
            lucid_puts(*lucid_preprocess_output(*a))
          end
        end
      end

      Kernel.extend(self)
      STDOUT.extend(self)
      STDERR.extend(self)
    end
  end
end
