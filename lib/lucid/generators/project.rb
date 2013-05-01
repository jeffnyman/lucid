require 'thor/group'

module Lucid
  module Generators
    class Project < Thor::Group
      include Thor::Actions

      argument :name,    type: :string,  desc: "Name of the project."
      argument :browser, type: :string,  desc: "Use for browser-based testing."
      argument :driver,  type: :string,  desc: "Framework driver to use."

      desc "Generates a project structure."

      def self.source_root
        File.dirname(__FILE__) + "/project"
      end

      def spit_back_values
        puts "Create project '#{name}'"
        puts "Use for browser-based apps." if use_browser
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

      def copy_errors
        copy_file "errors.rb", "#{name}/common/support/errors.rb"
      end

    private

      def use_browser
        browser == 'true'
      end
    end
  end
end