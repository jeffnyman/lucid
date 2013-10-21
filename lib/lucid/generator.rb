require 'thor'
require 'lucid/generators/project'

module Lucid
  class Generator < Thor
    desc 'project NAME', 'Create a new project.'

    #method_option :browser, aliases: "-b", type: :boolean, desc: "Use for browser-based testing."
    method_option :driver, aliases: '-d', type: :string, required: false, desc: "Framework driver to use. (Default value is 'fluent'.)"

    def project(name)
      puts "Name of project: #{name}"

      driver = options[:driver].nil? ? 'fluent' : options[:driver]
      #browser = options[:browser] == true ? 'true' : 'false'

      #Lucid::Generators::Project.start([name, browser, driver])
      Lucid::Generators::Project.start([name, driver])
    end
  end
end