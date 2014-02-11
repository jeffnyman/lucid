module Lucid
  module RSpec
    # In rspec/core/configuration, a method called load_spec_files is used
    # to call the Kernel.load method. Lucid overrides that method in order
    # to allow it to customize what files are loaded and then to hook into
    # the Lucid runner.
    module Loader
      def load(*paths)
        if paths.first.end_with?('.spec', '.feature', '.story')
          Lucid::RSpec.build(paths.first)
        end
      end
    end

    class << self
      def build(file)
        puts "File to build: #{file}"
      end
    end
  end
end

::RSpec::Core::Configuration.send(:include, Lucid::RSpec::Loader)

::RSpec.configure do |config|
  config.default_path = 'specs'
  config.pattern << ',**/*.spec,**/*.feature,**/*.story'
end
