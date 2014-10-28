===Project Description

Classes involved: grades_controller.rb
====What it does:
This class lists the grades of all the participants for an assignments and also their reviews. Instructor can edit scores, calculate penalties and send emails for conflicts.

====What needs to be done:

1. Modify calculate_all_penalties method which is too complex and long.

2. Put the get_body_text method in a mailer rather than in the grades_controller.

3. Refactor conflict_nofication method to conflict_email and make it delegated to the mailer.

4. Refactor view_my_scores method to grades_show and delete the unnecessary variables.

5. Try not to query for reviews and meta reviews in grades_show method.

====What we have done:

1. Modify calculate_all_penalties method.

2. Refactor the conflict_notification method to conflict_email method.

3. Simplify sending email function and make it delegated to the mailer.

4. Send a conflict email to the reviewer automatically when instructor click the button "email reviewer".
 
5. Remove get_body_text and send_grading_email method from grades_controller.

6. Refactor conflict_nofication method to conflict_email and make it delegated to the mailer.

7. Use Design Pattern Delegation in ConflictMailer.

8. Refactor view_my_scores method to grades_show method.

9. Search for the key reasons which lead to huge waiting time for getting score.

10. Refactor get_assessments_for method in response_map.rb and lead to more than 90\% off the original view scores' running time.

11. Eliminate the search for reviews and meta reviews during the grades_show method.

12. Delete unnecessary instance Variables.

=====Extra Credits:

1. Refactor get_assessments_for method in response_map.rb and lead to more than 90\% off the original view scores' running time.

2. Use Design Pattern Delegation in ConflictMailer.

3. Send a conflict email to the reviewer automatically when instructor click the button "email reviewer".

===The Website link for our team's work: 

======Note: In order to compare test results between current system and original system. You'd better test both system.

====Current System (After Refactoring Grades_controller): 

http://152.46.18.10:3000/

   Instructor: user6                     Password: test
   
   Student: user1600 and user1601        Password: test

====Original System (Before Refactoring Grades_controller):

http://152.1.13.97:3000/

   Instructor: user6                     Password: test
   
   Student: user1600 and user1601        Password: test

All our test result based on the following test cases on expertiza, please follow these step to get it.

====Instructor: (Searching "Program 2" using "Ctrl + F" will be convinient for you.)

======Steps: Login -> Assignments->Program 2 style ->view scores. 

====Student:

======Steps: Login -> Assignments->Program 2 style ->Your scores.

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
