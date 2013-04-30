require 'thor/group'

module Lucid
  module Generators
    class Project < Thor::Group
      include Thor::Actions

      argument :name, type: :string, desc: "Name of the project."

      desc "Generates a project structure."


    end
  end
end