require 'yaml'

module Lucid
  module CLI
    class Profile

      def initialize
        @lucid_yml = nil
      end

      def args_from(profile)
        unless lucid_yml.has_key?(profile)
          raise(ProfileNotFound, <<-END_OF_ERROR)
Could not find profile: '#{profile}'

Defined profiles in lucid.yml:
  * #{lucid_yml.keys.sort.join("\n  * ")}
        END_OF_ERROR
        end

        args_from_yml = lucid_yml[profile] || ''

        case(args_from_yml)
          when String
            raise YmlLoadError, ["The '#{profile}' profile in lucid.yml was blank. You must define",
                                 "command line arguments if you are are going to include a profile",
                                 "in lucid.yml.\n"].join("\n") if args_from_yml =~ /^\s*$/
            if(Lucid::WINDOWS)
              args_from_yml = args_from_yml.split
              args_from_yml = args_from_yml.collect {|x| x.gsub(/^\"(.*)\"/,'\1') }
            else
              require 'shellwords'
              args_from_yml = Shellwords.shellwords(args_from_yml)
            end
          when Array
            raise YmlLoadError, ["The '#{profile}' profile in lucid.yml contained an empty array.",
                                 "You must define any command line arguments within the array.\n"].join("\n") if args_from_yml.empty?
          else
            raise YmlLoadError, ["The '#{profile}' profile in lucid.yml was a #{args_from_yml.class}.",
                                 "A profile must be a a String or an Array."].join("\n")
        end
        args_from_yml
      end

      def has_profile?(profile)
        lucid_yml.has_key?(profile)
      end

      def lucid_yml_defined?
        lucid_file && File.exist?(lucid_file)
      end

    private

      # Loads the profile, processing it through ERB and YAML, and returns it as a hash.
      def lucid_yml
        return @lucid_yml if @lucid_yml
        unless lucid_yml_defined?
          raise ProfilesNotDefinedError, ["A lucid.yml file was not found. The current directory is #{Dir.pwd}.",
                                          "Refer to Lucid's documentation on defining profiles in lucid.yml.",
                                          "You must define a 'default' profile to use the lucid command without",
                                          "any arguments.\nType 'lucid --help' for usage.\n"].join("\n")
        end

        require 'erb'
        require 'yaml'
        begin
          @lucid_erb = ERB.new(IO.read(lucid_file)).result(binding)
        rescue Exception => e
          raise YmlLoadError, ["A lucid.yml file was found, but could not be parsed. Double-check",
                               "the contents of the file. Refer to Lucid's documentation on correct",
                               "profile usage.\n#{$!.inspect}"].join("\n")
        end

        begin
          @lucid_yml = YAML::load(@lucid_erb)
        rescue StandardError => e
          raise YmlLoadError, ["A lucid.yml file was found, but could not be parsed. Double-check",
                               "the contents of the file. Refer to Lucid's documentation on correct",
                               "profile usage.\n"].join("\n")
        end

        if @lucid_yml.nil? || !@lucid_yml.is_a?(Hash)
          raise YmlLoadError, ["The lucid.yml file was found, but was blank or malformed. Please",
                               "refer to Lucid's documentation on defining profiles in lucid.yml.\n"].join("\n")
        end

        return @lucid_yml
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

