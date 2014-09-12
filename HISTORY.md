Change Log and History
======================

Version 0.5.1 / 2014-09-12
--------------------------

Backed out some of the Cucumber-like changes.

Version 0.5.0 / 2014-09-07
--------------------------

This version of Lucid allows it to act more like Cucumber by recognizing the same type of `features` directory as Cucumber does. Lucid still defaults to a `specs` directory but now if you are using a `features` directory, the standard structure will be recognized. The driver file has been changed to Cucumber's default of `env.rb`. Previously this was `driver.rb` but there was little reason to diverge from Cucumber here. You can still set up a custom driver file via the command line.
 
Note that with the upcoming final release of Cucumber 2.x it's up in the air how much and to what extent I'll support Lucid in its current incarnation. So far Cucumber 2.x doesn't seem to offer anything much but the hexagonal architecture might be worth exploring. In preparation for this the strict build and code coverage process for Lucid has been removed as have the unit tests.

Version 0.4.1 / 2013-02-18
--------------------------

This is a hotfix release that corrects an issue where executing with a profile specified could lead to the entirety of your test repo files not being red. The issue was the reverse merge mechanism that is used to reconcile how Lucid deals with command execution based on where it got information from, which can currently be the defaults that Lucid provides, the information specified in lucid.yml (and run as a profile), or information specified via the command line.

Version 0.4.0 / 2013-02-15
--------------------------

A large purpose for this release of Lucid is to clean up the internals of the code base, in particular naming code structures in such a way that they are more reflective of what they actually do. This release is very much in the category of tech-debt reduction.

* This version of Lucid removes the project generator (lucid-gen) that was originally part of it. That project has been separated off into its own project [LucidGen](https://github.com/jnyman/lucid-gen). This, at least partially, responds to the issue [External Project Generator Mechanism](https://github.com/jnyman/lucid/issues/14).

* A slightly better logging mechanism is in place such that executing Lucid with `--debug` specified will now provide a much better output of objects, making it easier to determine the internal state of Lucid's operations. Included with this is debug output of the AST when a spec file is read.

* A change has been put in place regarding how the `--dry-run` functionality works. Prior to this release, the driver file (by default, common/support/driver.rb) would not be included when you performed a dry-run against your repository. That's still in place but now Lucid will also exclude any page or activity definition files. This was found to be necessary because those files will often utilize elements that are required in the driver file.

* It is now possible to specifically indicate, via the command line, the steps path (by default, steps) and the definitions page (by default, pages). The latter is meant to build in support for the concept of page objects.

Version 0.3.3 / 2013-02-13
--------------------------

This patch release reverts patch releases 0.3.1 and 0.3.2. Both of those patches were put in place to start on a different execution mode for Lucid. That execution mode, however, has proven more problematic than I would have preferred. Patch 0.3.3 essentially puts Lucid back to 0.3.0, albeit with a few structural enhancements.

Version 0.3.0 / 2013-11-05
--------------------------

* Lucid now allows multiple spec file types. ([Allow Multiple Spec Files](https://github.com/jnyman/lucid/issues/6))

Prior to this, Lucid would only recognize one spec file type. It was `.spec` by default or you could specify another one via the --spec-type option. Now Lucid will recognize `.feature`, `.spec`, and `.story` by default. Further, it will execute all such test spec files if it finds them. You can also still specify a custom file type via the --spec-type option. In that case Lucid will recognize your custom file type as well as all the standard ones.

Lucid already uses the concept of a Domain, which is similar to Cucumber's World concept. Lucid now lets you refer to the Domain as World. This allows those familiar with Cucumber to use that wording and it also allows Lucid to better integrate into the Cucumber ecosystem.

The project generator for creating Fluent projects has been updated. The main change of note here is that the `lucid.yml` configuration file is no longer automatically generated. The reason for this is that Lucid operation requires no configuration at all if the conventions in place are what you want to use.

Version 0.2.1 / 2013-10-21
--------------------------

This is a small patch release. The patch is in the project generator. The [Symbiont](https://github.com/jnyman/symbiont) test framework is being deprecated in favor of [Fluent](https://github.com/jnyman/fluent). The project generator has been updated accordingly.

Version 0.2.0 / 2013-09-28
--------------------------

This release introduces a fairly major change, which is that of sequences. The idea is that you can define sequence phrases that are used to stand in for a set of steps. That set of steps is the sequence. This is essentially a macro-like functionality for Lucid. It's uncertain how long this functionality will exist since it potentially harbors some questionable design choices when it comes to an expressive TDL.

This release also introduces a new formatter called "condensed." This formatter is used simply to display a much more limited set of information about the scenarios that are being executed. Specifically, all that gets returned are the scenario titles, essentially hiding all of the steps. Pass/fail information is still reported.

Version 0.1.1 / 2013-06-04
--------------------------

This patch release was needed to fix one issue and update a gem dependency.

* The Symbiont project generator now no longer has any logic in the driver.rb file, which is necessary in order to allow the --dry-run option to work without error.

* I am trusting multi_json again by including just it and not forcing Ruby's built-in json gem. This is based on the issue [Incorrectly Reporting Old or Stdlib Json?](https://github.com/intridea/multi_json/issues/114) that I originally raised and finally had a response with the [Remove stdlib warning since it's doing more harm than good](https://github.com/intridea/multi_json/pull/122) update to multi_json.

Version 0.1.0 / 2013-06-02
--------------------------

The main focus of this release is some back end changes to simplify and speed up Lucid operation. Of particular note, this release has modified the Lucid Symbiont project that gets generated from the lucid-gen tool. There were errors in that project that made working with browsers problematic.

Lucid is now entering its "initial development phase", notwithstanding the fact that Lucid has already been in initial development. At this point Lucid has proven stable enough to write a series of blog articles on describing how to use it. That, for the time being, is serving as the "public API" or reference implementation. Upcoming releases will more often than not be focusing on feature inclusion as opposed to small updates and internal fixes.


Version 0.0.9 / 2013-05-22
--------------------------

This version is being released to introduce a few more behind-the-scenes logic refactorings and also to fix a specific bug.

* Lucid was still indicating it could use non-Ruby languages. ([Matchers In Different Languages?](https://github.com/jnyman/lucid/issues/11).)

As a note, this is the final "patch" version of Lucid prior to going to a semantic versioning approach. Lucid will next enter the initial development phase.

Version 0.0.8 / 2013-05-20
--------------------------

This version is being released to bring in two specific bug fixes.

* Certain profile options were not being recognized. ([Spec Type Specified in Profile Not Recognized](https://github.com/jnyman/lucid/issues/10).)
* The strict mode now works more as intended. ([Using "strict" Does Not Return Errors](https://github.com/jnyman/lucid/issues/8).)

Version 0.0.7 / 2013-05-17
--------------------------

This version mainly makes a lot of internal changes and many of those are predicated upon keeping pace with the changes that Cucumber is making as they move to their 2.0 release.

Two specific changes worth calling out:

* Lucid will now let you reliably configure a library path.
* Lucid will allow you to configure the name of the driver file. (This was due to a [planned enhancement](https://github.com/jnyman/lucid/issues/2)].)

The driver file in Cucumber is env.rb. In Lucid this defaults to driver.rb. Now, however, you can override that default. Regarding the library path, this is equivalent to what Cucumber refers to as the "support" directory. The main reason for these changes is that Lucid is trying to be a little more configurable than Cucumber.

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
