module Lucid
  # The base class for configuring settings for a Lucid run.
  class Configuration
    def self.default
      new
    end

    def self.parse(argument)
      return new(argument) if argument.is_a?(Hash)
      argument
    end

    def initialize(user_options = {})
      @options = default_options.merge(user_options)
    end

    def dry_run?
      @options[:dry_run]
    end

    def guess?
      @options[:guess]
    end

    def strict?
      @options[:strict]
    end

    def expand?
      @options[:expand]
    end

    def spec_source
      @options[:spec_source]
    end

    def autoload_code_paths
      @options[:autoload_code_paths]
    end

    def matcher_type
      @options[:matcher_type]
    end

  private

    def default_options
      {
        :autoload_code_paths => ['common/support', 'steps']
      }
    end
  end
end
