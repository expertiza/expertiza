Expertiza Refactoring for: review_response_map.rb Model.

path of files: app/models/review_response_map.rb
               test/unit/review_response_map_test.rb

Link to deployed project: http://152.46.16.195:5902/


Credentials:
(as an instructor)
username: instructor6
password: password

(as a student)
username: student559 / student13
password: password


ReviewResponseMap is the model class used to manage the relationship between contributors, reviewers, and assignments. The intent of the changes were to refactor the code for better readability and adherence to Ruby coding standards and best practices. Primarily these changes involved the refactoring of overly complex methods, renaming methods for better readability, and the addition of missing unit tests.
Project Requirements:
Code Climate shows import method is complex, because of lots of checks. This method can be fixed by adding private methods for raising import error.
Get_assessments_round_for method can be renamed to get_team_responses_for_round. Team_id private variable is not needed.
metareview_response_maps rename, refactoring can be done. No need to do second iteration.
write missing unit tests for existing methods.

NOTE: You can view more admins and users after logging in as instructor6 then going to: Manage > Users
 And login as any of the users. All the default passwords are 'password'. You may create new users in
 the same place.
 You could also impersonate user when logged in as "instructor6", eg: "student559" by going to
 "Manage > Impersonate User > student559 " . You do not need to punch in the password to impersonate users.
 You can only impersonate users created by that admin. eg: You cannot impersonate 'student13' when logged in
 as 'instructor6'.


 Code improved were based on the criteria given as a requirement as well as a few suggestions and changes
 from CodeClimate.
 The rating improved from a C to a B. Some improvements could not be made because of several reasons.
 One reason was that the Class has too many lines. This could not be helped because of the addition of private
 methods and functionality required by the class.
 Another reason is a bug from rubocop which recommends us to use find_by instead of where(..).first.
 They have suggested that they fix this is a newer release of rubocop.
 Link: https://github.com/bbatsov/rubocop/issues/1938

To run the Unit Tests:

1. Download the master branch of the repo.
2. Setup the Databases for the test environment (we have used Zhewei's scrubbed expertiza DB )
    2.a Run the " rake db:create RAILS_ENV=test " command
    2.b Run the " rake db:reset RAILS_ENV=test " command
    2.c Scrub the DB using " mysql -u root expertiza_development < expertiza-scrubbed.sql"
    2.d Run the " rake db:migrate "
3. run " rake test test/unit/review_response_map_test.rb " in the "expertiza/" directory.
4. Check if tests passed or failed.

NOTE: There were many tests that did not work before, they were deleted and new tests were added.




Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.png?branch=master)](https://travis-ci.org/expertiza/expertiza)
[![Code Climate](https://codeclimate.com/github/expertiza/expertiza.png)](https://codeclimate.com/github/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/expertiza/expertiza/badge.png?branch=master)](https://coveralls.io/r/expertiza/expertiza?branch=rails4)
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
