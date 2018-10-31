To Do:

OSS project testing:

[] Test CRUD questionnaire (Sam)

[] Test CRUD quiz questionnaire (Sam)

[] Test import, export, copy_questionnaire_details, and
assign_instructor_id in quiz_questionnaire model (Sam)

[] Test valid_quiz in questionnaire model (Sam)

[] Test toggle_access in questionnaire model  (Sam)
	-- for this one, leave it alone, ask Bhavik about it and worry about it later

[] Test set_display_type in questionnaire model (Sam)

OSS Project to do:

[] Move case statement from create in questionaire_controller.rb into
a method called set_display_type in questionaire model (Reddy) - Done

[] Delete create_questionnaire method and replace the call to it in
create_quiz_questionnaire with the code of create_questionnaire. Also,
in an Object Oriented system, you should not have to check the type of
an object. (Reddy) - Done

[] Move view_quiz to quiz_questionnaires_controller.rb, and rename it view
(Abhisu)

[] Move new_quiz to quiz_questionnaires_controller.rb, and rename it new
(Abhisu)

[] Move create_quiz_questionnaire to quiz_questionnaires_controller.rb and
rename it create
(Abhisu)

[] Move edit_quiz to quiz_questionnaires_controller.rb and rename it edit
(Abhisu)

[] Move update_quiz to quiz_questionnaires_controller.rb and rename it update
(Abhisu)

[] Move large block of for and if statements into method called
change_question_types in the quiz_questionnaire model. (Reddy) - Done

[] Replace large block of for and if statements in update_quiz with a call
to the new change_question_types method. (Reddy) - Done

[] Move valid_quiz into quiz_questionnaire model and rename it valid? (Abhisu) - Done

[] Move export, import, copy_questionnaire_details, and assign_instructor_id
to questionaire model. (Reddy) - Done - Tested Export.


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
 * Follow the [design guidelines](https://github.com/expertiza/expertiza/blob/master/design_document.md) for the views.

When editing existing files:

 * Keep the existing tabbing (use tabs instead of spaces in files that already use tabs everywhere; otherwise use spaces)
 * Keep the existing line ending style (dos/unix)
 * Follow the Ruby style Guide on code you add or edit, as above

Please do no go crazy changing old code to match these guidelines; it will just create lots of potential merge conflicts.
Applying style guidelines to code you add and modify is good enough. :-)
