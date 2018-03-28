Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.svg?branch=master)](https://travis-ci.org/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/github/expertiza/expertiza/badge.svg?branch=master)](https://coveralls.io/github/expertiza/expertiza?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/f3a41f16c2b6e45aa9d4/maintainability)](https://codeclimate.com/github/expertiza/expertiza/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f3a41f16c2b6e45aa9d4/test_coverage)](https://codeclimate.com/github/expertiza/expertiza/test_coverage)
#### Peer review system

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

Setup
-----

### NCSU VCL image

The expertiza environment is already set up in [NC State's VCL](https://vcl.ncsu.edu) image "Ruby on Rails".
If you have access, this is quickest way to get a development environment running for Expertiza.
See the Google doc on [setting up the Expertiza development environment](https://docs.google.com/document/d/1tXmwju6R7KQbvycku-bdXxa6rXSUN4BMyvjY3ROmMSw/edit).

Using the VCL is the quickest way to get started, but you may find it awkward developing on a remote machine
with network lag and having to reinstall gems every time you connect. Installing locally can be a pain though too.
Life is full of tradeoffs. :-) The good news is that you can start on one environment, push your work to git,
and switch to another environment if you don't like the one you started with.

### Installing locally

See the Expertiza wiki for setup instructions. Please update the wiki with corrections or additional helpful information.

 * [OSX](http://wiki.expertiza.ncsu.edu/index.php/Development:Setup:OSX)
 * [RedHat Linux](http://wiki.expertiza.ncsu.edu/index.php/Development:Setup:Linux:RHEL)
 * [Ubuntu](http://wiki.expertiza.ncsu.edu/index.php/Creating_a_Linux_Development_Environment_for_Expertiza_-_Installation_Guide)
 * [Docker-compose](https://github.com/expertiza/expertiza/tree/master/docker)

Contributing
------------

 * [Fork](http://help.github.com/fork-a-repo/) the expertiza project
 * [Create a new branch](http://progit.org/book) for your contribution with a descriptive name
 * [Commit and push](http://progit.org/book) until you are happy with your contribution - follow the style guidelines below
 * Make sure to add tests for it; the tests should fail before your contribution/fix and pass afterward
 * [Send a pull request](http://help.github.com/send-pull-requests) to have your code reviewed for merging back into Expertiza

Style Guidelines
----------------

We've had many contributors in the past who have used a wide variety of ruby coding styles. It's a mess, and we're trying to unify it.

All new files/contributions should:

 * Use unix line endings (Windows users: configure git to use [autocrlf](http://help.github.com/line-endings))
 * Indent with 2 spaces (no tabs; configure your editor) both in ruby and erb
 * Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) style for syntax, formatting, and naming

When editing existing files:

 * Keep the existing tabbing (use tabs instead of spaces in files that already use tabs everywhere; otherwise use spaces)
 * Keep the existing line ending style (dos/unix)
 * Follow the Ruby style Guide on code you add or edit, as above

Please do no go crazy changing old code to match these guidelines; it will just create lots of potential merge conflicts.
Applying style guidelines to code you add and modify is good enough. :-)

####################
Begin adding Issues 971, 926, 718
####################