We have refactored the DynamicReviewMapping controller (helper). As a part of this assignment we carried out the following tasks:


1. The code block between line 808 to 825 was duplicated in 3 places in this file. We have refactored the code to remove this bad smell. We have created a method called create_message to avoid duplication in the code.
2. Method assign_metareviewers, assign_reviewers_team were too long. We have made two new methods (check_assignment_for_review and show_message_for_review_count) that does just one task and does it perfectly instead of large methods to do multiple tasks.
3. Method assign_reviewers_individual was not used anymore. We have checked for its functionality and deleted it since it did not play any role in the final application.
4. We have changed if to unless wherever necessary.
5. Changed " == 0" expression to ".zero?"
6. Used `if (var)` instead of `if (var == true)`
7. We have used array checking and made changes according to the follwing rules:
    * Use [].empty? instead of [].length == 0 or [].length.zero?
    * Use [:foo].any? instead of [:foo].length > 0
    * Use [:foo].one? instead of [:foo].length == 1
    * Use [:foo].first instead of [:foo][0]
    * Use [:foo].last instead of [:foo][-1]

8. We have used `&&` and `||` rather than `and` and `or` to keep boolean precedence.


This really isn't any different from refactoring projects, which don't change functionality. In our case, we have removed some classes, and the reviewers can verify that the functionality associated with reviews still works.


Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.png?branch=master)](https://travis-ci.org/expertiza/expertiza)
[![Code Climate](https://codeclimate.com/github/expertiza/expertiza.png)](https://codeclimate.com/github/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/expertiza/expertiza/badge.png?branch=master)](https://coveralls.io/r/expertiza/expertiza?branch=master)
#### Peer review system

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

Setup
-----

### NCSU VCL image

The expertiza environment is already set up in [NC State's VCL](https://vcl.ncsu.edu) image "Ruby on Rails".
If you have access, this is quickest way to get a development environment running for Expertiza.
See the Expertiza wiki on [developing Expertiza on the VCL](http://wikis.lib.ncsu.edu/index.php/Developing_Expertiza_on_the_VCL).

Using the VCL is the quickest way to get started, but you may find it awkward developing on a remote machine
with network lag and having to reinstall gems every time you connect. Installing locally can be a pain though too.
Life is full of tradeoffs. :-) The good news is that you can start on one environment, push your work to git,
and switch to another environment if you don't like the one you started with.

### Installing locally

See the Expertiza wiki for setup instructions. Please update the wiki with corrections or additional helpful information.

 * [OSX](http://wikis.lib.ncsu.edu/index.php/Creating_a_Mac_OS_X_Development_Environment_for_the_Expertiza_Application)
 * [Linux](http://wikis.lib.ncsu.edu/index.php/Creating_a_Linux_Development_Environment_for_the_Expertiza_Application)
 * [Windows](http://wikis.lib.ncsu.edu/index.php/Creating_a_Windows_Development_Environment_for_the_Expertiza_Application)

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
