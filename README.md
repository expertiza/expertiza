Expertiza
=========

<<<<<<< HEAD
[![Build Status](https://travis-ci.org/expertiza/expertiza.png?branch=rails4)](https://travis-ci.org/expertiza/expertiza)
[![Code Climate](https://codeclimate.com/github/expertiza/expertiza.png)](https://codeclimate.com/github/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/expertiza/expertiza/badge.png?branch=rails4)](https://coveralls.io/r/expertiza/expertiza?branch=rails4)

###E1510. Fix Instructor Login Performance Issue
###Problem description
Currently when an Instructor logs into Expertiza,there a lot of select* from assignments queries being fired on database which would have an adverse effect on performance.
Analyze and reduce the number of select queries executed to improve the performance.
####Screenshot of console when Instructor logs in
<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/before_modify.png" style="float:left;with:100px;height:300px">
There are six select assignment queries after load _row_header.html.erb
###Use [Query Reviewer](https://github.com/nesquena/query_reviewer) to trace the queries

<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/query_reviewer.png" style="float:left;with:100px;height:300px">
We use Query Reviewer to trace the queries and found the where the queries are executed multiply times.

###What we do to fix it
* We found that the _row_header.html.erb file called methods form assignment_node.rb, which executed the select assignment queries multiple times, which are redundant.
After modifying the methods,the performance is highly improved.
* We also modified _assignments_actions.html.erb to further improve the performance.

####Screenshot of console when Instructor logs in after modification
<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/after_modify.png" style="float:left;with:100px;height:300px">

As shown above,there is only one query executed after _row_header.html.erb is loaded.
The time consumption has been reduced dramatically.(Dropped from 900+ms to 200+ms)
=======
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
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7
