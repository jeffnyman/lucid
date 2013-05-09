Change Log and History
======================


Version 0.0.6 / 2013-05-09
--------------------------

This version attempts to fix a few issues to improve general operation.

* Lucid now lists an explicit dependency on json. (This was due to [an issue with multi_json](https://github.com/intridea/multi_json/issues/114).)
* Invalid command line options are now handled better. ([Invalid Command Line Options Needs Better Handling](https://github.com/jnyman/lucid/issues/1).)
* Lucid now handles missing directories without raising exceptions. ([Extraneous "No File or Directory" Messages](https://github.com/jnyman/lucid/issues/3).)
* The default generator project recognizes a missing Symbiont gem. ([Stack Trace When Symbiont Not Installed](https://github.com/jnyman/lucid/issues/5).)


Version 0.0.5 / 2013-05-04
--------------------------

This is the first version of Lucid that attempts to be a clone of BDD tools like Cucumber. There are some changes that Lucid will provide out of the starting gate. Here are a few of those:

* The `env.rb` file is now called `driver.rb`.
* The repository directory is now called `specs` rather than `features`.
* The extension type for files is now `.spec` rather than `.feature`.
* There is a project generator that will create a new type of proposed file structure.

Lucid is aiming to be more flexible than other tools, so certain elements -- like the extension for files and the repository directory -- are configurable. As time goes on, Lucid will diverge in some ways from other BDD tools. In other ways, however, it will remain consistent with them. For example, Lucid does adhere to the Gherkin API just as Cucumber and SpecFlow do. Lucid does not, however, currently fully support the wire protocol as Cucumber does.

This is very much an alpha release to determine how feasible Lucid is as a tool.


Versions 0.0.1 to 0.0.4
-----------------------

These initial versions of Lucid were designed to serve as nothing more than a wrapper for Cucumber. The goal was to allow for an easier way to work around the opinionated nature of tools like Cucumber in terms of how they expected your projects to be setup.