require 'thor'
require 'lucid/generators/project'

module Lucid
  class Generator < Thor
    desc "project NAME", "Create a new project."

    def project(name)
      puts "Name of project: #{name}"

      Lucid::Generators::Project.start([name])
    end
  end
end