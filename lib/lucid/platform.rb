require 'rbconfig'

module Lucid
  unless defined?(Lucid::VERSION)
    VERSION       = '0.0.4'
    BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/lucid')
    LIBDIR        = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    JRUBY         = defined?(JRUBY_VERSION)
    IRONRUBY      = defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
    WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    OS_X          = RbConfig::CONFIG['host_os'] =~ /darwin/
    WINDOWS_MRI   = WINDOWS && !JRUBY && !IRONRUBY
    RAILS         = defined?(Rails)
    RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    RUBY_2_0      = RUBY_VERSION =~ /^2\.0/
    RUBY_1_9      = RUBY_VERSION =~ /^1\.9/

    class << self
      attr_accessor :use_full_backtrace

      def file_mode(m, encoding="UTF-8")
        "#{m}:#{encoding}"
      end
    end
    self.use_full_backtrace = false
  end
end
