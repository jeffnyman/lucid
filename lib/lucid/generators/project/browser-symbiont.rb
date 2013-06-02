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
