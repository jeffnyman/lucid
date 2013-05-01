require 'thor/group'

module Lucid
  module Generators
    class Project < Thor::Group
      include Thor::Actions

      argument :name, type: :string, desc: "Name of the project."

      desc "Generates a project structure."

      def spit_back_values
        puts "Create project '#{name}'"
      end

      def create_project_directory
        empty_directory(name)
      end

      def create_project_structure
        empty_directory("#{name}/specs")
        empty_directory("#{name}/common")
        empty_directory("#{name}/common/helpers")
        empty_directory("#{name}/common/support")
        empty_directory("#{name}/common/config")
        empty_directory("#{name}/common/data")
        empty_directory("#{name}/steps")
        empty_directory("#{name}/pages")
      end

    end
  end
end