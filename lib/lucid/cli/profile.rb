module Lucid
  module CLI
    class Profile

      def initialize
        @lucid_profile = nil
      end

      def lucid_yml_defined?
        lucid_file && File.exist?(lucid_file)
      end

      def has_profile?(profile)
        lucid_profile.has_key?(profile)
      end

    private

      def lucid_profile
        unless lucid_yml_defined?
          raise ProfilesNotDefinedError, ["A lucid.yml file was not found. The current directory is #{Dir.pwd}.",
                                          "If you have a profile file, then you must define a 'default' profile",
                                          "within it. Please refer to Lucid's documentation on defining profiles",
                                          "in lucid.yml.\nType 'lucid --help' for usage.\n"].join("\n")
        end
      end

      # Locates lucid.yml file. The file can end in .yml or .yaml, and be
      # located in the current directory (e.g., project root) or in a
      # .config/ or config/ subdirectory of the current directory.
      def lucid_file
        @lucid_file ||= Dir.glob('{,.config/,config/}lucid{.yml,.yaml}').first
      end

    end
  end
end