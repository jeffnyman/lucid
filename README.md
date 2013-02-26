# Lucid

Lucid is a shiv around BDD tools. Currently the only such tool that Lucid intercepts calls to is Cucumber. The reason for this is that many of these BDD tools are highly opinionated in their structure. While most tools do have a way to force the structure to be your way, how this is done is not always consistent.

By way of example, Cucumber expects features to live in a directory called features and step definitions to live in a directory called step_definitions that is under the features directory. When running a feature, all step definitions are loaded unless you explicitly require just the ones you want. If you structure your project differently from how Cucumber expects, then you have to require files explicitly.

Lucid allows you to specify configuration options that are then passed to Cucumber.

## Installation

Add this line to your application's Gemfile:

    gem 'lucid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lucid

## Usage

Lucid can be configured project by project through the use of a lucid.yml file that lives in the root of your project. This file will contain configurable options. These options will be indicated by specific declarations.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
