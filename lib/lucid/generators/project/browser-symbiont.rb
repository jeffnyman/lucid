begin
  require 'symbiont'
  require 'symbiont/factory'
rescue LoadError
  STDOUT.puts ["The Symbiont test execution library is not installed.",
               "The driver file is currently set to use the Symbiont library but",
               "that gem was not found. Run the following command:", "",
               "  gem install symbiont"].join("\n")
  Kernel.exit(1)
end

Domain(Symbiont::Factory)

module Symbiont
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
