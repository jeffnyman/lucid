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