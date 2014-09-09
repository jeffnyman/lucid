Lucid
=====

[![Code Climate](https://codeclimate.com/github/jnyman/lucid.png)](https://codeclimate.com/github/jnyman/lucid)
[![Dependency Status](https://gemnasium.com/jnyman/lucid.png)](https://gemnasium.com/jnyman/lucid)
[![Gem Version](https://badge.fury.io/rb/lucid.png)](http://badge.fury.io/rb/lucid)


Description
-----------

Lucid is a Description Language specification and execution engine.  Here the Description Language can be considered a TDL (Test Description Language) or BDL (Business Description Language). I'm not even sure if those are official terms but they are the terms I use to indicate the language whereby elaborated requirements and tests become largely the same artifact.

Lucid is a clone of the popular tool [Cucumber](http://cukes.info/). Lucid is diverging in many ways from Cucumber but it does owe much of its initial structure to it. Lucid will also be incorporating some of the good ideas that have come to light in tools like [Spinach](https://github.com/codegram/spinach) and [Turnip](https://github.com/jnicklas/turnip).

Lucid is currently in an extended beta period, essentially becoming its own entity in the world of BDD tools.


Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'lucid'
```

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install lucid


Using Lucid
-----------

Right now the best way to learn about Lucid is to check out some of my [blog posts related to Lucid](http://testerstories.com/category/lucid/). They will take you through various aspects of using the framework.

In order to to check what options are available to you from the command line, do this:

    $ lucid --help


Contributing
------------

[Suggest an Improvement](https://github.com/jnyman/lucid/issues) or [Report a Bug](https://github.com/jnyman/lucid/issues)

To work on Lucid:

1. [Fork the project](http://gun.io/blog/how-to-github-fork-branch-and-pull-request/).
2. Create a feature branch. (`git checkout -b my-new-feature`)
3. Commit your changes. (`git commit -am 'new feature'`)
4. Push the branch. (`git push origin my-new-feature`)
5. Create a new [pull request](https://help.github.com/articles/using-pull-requests).
