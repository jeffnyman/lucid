begin
  require 'fluent'
rescue LoadError
  STDOUT.puts ['The Fluent test execution library is not installed.',
               'The driver file is currently set to use the Fluent library but',
               'that gem was not found. Run the following command:', '',
               '  gem install fluent'].join("\n")
  Kernel.exit(1)
end

Domain(Fluent::Factory)

module Fluent
  module Browser

    @@browser = false

    def self.start
      unless @@browser
        target = ENV['BROWSER'] || 'firefox'
        @@browser = watir_browser(target)
      end
      @@browser
    end

    def self.stop
      @@browser.quit if @@browser
      @@browser = false
    end

  private

    def self.watir_browser(target)
      Watir::Browser.new(target.to_sym)
    end
  end
end
