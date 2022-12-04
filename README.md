Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.svg?branch=main)](https://travis-ci.org/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/github/kailash1998s/expertiza/badge.svg?branch=main)](https://coveralls.io/github/kailash1998s/expertiza?branch=main)[![Maintainability](https://api.codeclimate.com/v1/badges/23b8a211854207919986/maintainability)](https://codeclimate.com/github/expertiza/expertiza/maintainability)

#### Peer review system

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

Setup
-----

### NCSU VCL image

The expertiza environment is already set up in [NC State's VCL](https://vcl.ncsu.edu) image "[CSC517, S18] Ruby on Rails / Expertiza".

Using the VCL is the quickest way to get started, but you may find it awkward developing on a remote machine
with network lag and having to reinstall gems every time you connect. Installing locally can be a pain though too.
Life is full of tradeoffs. :-) The good news is that you can start on one environment, push your work to git,
and switch to another environment if you don't like the one you started with.

### Installing locally

See the Google doc on [setting up the Expertiza development environment](https://docs.google.com/document/d/1tXmwju6R7KQbvycku-bdXxa6rXSUN4BMyvjY3ROmMSw/edit).


<sub>Depreciation warning: See the Expertiza wiki for setup instructions. Please update the wiki with corrections or additional helpful information. (http://wiki.expertiza.ncsu.edu/index.php/Development:Setup:OSX, http://wiki.expertiza.ncsu.edu/index.php/Development:Setup:Linux:RHEL, http://wiki.expertiza.ncsu.edu/index.php/Creating_a_Linux_Development_Environment_for_Expertiza_-_Installation_Guide)</sub>

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
 * Follow the [design guidelines](https://github.com/expertiza/expertiza/blob/main/design_document.md) for the views.

When editing existing files:

 * Keep the existing tabbing (use tabs instead of spaces in files that already use tabs everywhere; otherwise use spaces)
 * Keep the existing line ending style (dos/unix)
 * Follow the Ruby style Guide on code you add or edit, as above

Please do no go crazy changing old code to match these guidelines; it will just create lots of potential merge conflicts.
Applying style guidelines to code you add and modify is good enough. :-)


Instructions to get production database ssh into a computer running Expertiza, e.g., an NCSU VCL node. 
ssh into expertiza.csc.ncsu.edu 
On production server, run mysqldump -uroot -p --databases expertiza_production > dump.sql #exports database from production 
On VCL, run sudo iptables -I INPUT -p TCP -s <IP_OF_PRODUCTION> -j ACCEPT #allows SCP requests 
Run SCP to your VCL scp dump.sql <unity_id>@<VCL_IP>:/home/<unity_id> 
mysql -uroot -p expertiza_development < dump.sql #loads database into production
