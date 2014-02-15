require 'lucid/platform'

module Lucid
  # Raised if the number of a StepDefinition's Regexp match groups
  # is different from the number of Proc arguments.
  class ArityMismatchError < StandardError
  end
end

class String
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, '')
    end
  end
end

class Proc
  PROC_PATTERN = /[\d\w]+@(.+):(\d+).*>/
  PWD = Dir.pwd

  def to_comment_line
    "# #{file_colon_line}"
  end

  def backtrace_line(name)
    "#{file_colon_line}:in `#{name}'"
  end

  if Proc.new{}.to_s =~ PROC_PATTERN
    def file_colon_line
      path, line = *to_s.match(PROC_PATTERN)[1..2]
      path = File.expand_path(path)
      pwd = File.expand_path(PWD)
      pwd.force_encoding(path.encoding)
      if path.index(pwd)
        path = path[pwd.length+1..-1]
      elsif path =~ /.*\/gems\/(.*\.rb)$/
        path = $1
      end
      "#{path}:#{line}"
    end
  else
    STDERR.puts '*** This implementation of Ruby does not report file and line information for procs. ***'

    def file_colon_line
      'UNKNOWN:-1'
    end
  end
end

class Object
  def lucid_instance_exec(check_arity, pseudo_method, *args, &block)
    lucid_run_with_backtrace_filtering(pseudo_method) do
      if check_arity && !lucid_compatible_arity?(args, block)
        instance_exec do
          ari = block.arity
          ari = ari < 0 ? (ari.abs-1).to_s + '+' : ari
          s1 = ari == 1 ? '' : 's'
          s2 = args.length == 1 ? '' : 's'
          raise Lucid::ArityMismatchError.new(
            "Your block takes #{ari} argument#{s1}, but the expression matched #{args.length} argument#{s2}."
          )
        end
      else
        instance_exec(*args, &block)
      end
    end
  end

  private

  def lucid_compatible_arity?(args, block)
    return true if block.arity == args.length
    if block.arity < 0
      return true if args.length >= (block.arity.abs - 1)
    end
    false
  end

  def lucid_run_with_backtrace_filtering(pseudo_method)
    begin
      yield
    rescue Exception => e
      instance_exec_invocation_line = "#{__FILE__}:#{__LINE__ - 2}:in `lucid_run_with_backtrace_filtering'"
      replace_instance_exec_invocation_line!((e.backtrace || []), instance_exec_invocation_line, pseudo_method)
      raise e
    end
  end

  INSTANCE_EXEC_OFFSET = (Lucid::RUBY_2_0 || Lucid::RUBY_1_9 || Lucid::JRUBY) ? -3 : -4

  def replace_instance_exec_invocation_line!(backtrace, instance_exec_invocation_line, pseudo_method)
    return if Lucid.use_full_backtrace

    instance_exec_pos = backtrace.index(instance_exec_invocation_line)
    if instance_exec_pos
      replacement_line = instance_exec_pos + INSTANCE_EXEC_OFFSET
      backtrace[replacement_line].gsub!(/`.*'/, "`#{pseudo_method}'") if pseudo_method

      depth = backtrace.count { |line| line == instance_exec_invocation_line }
      end_pos = depth > 1 ? instance_exec_pos : -1

      backtrace[replacement_line+1..end_pos] = nil
      backtrace.compact!
    else
      # Not sure what should happen here.
    end
  end
end
