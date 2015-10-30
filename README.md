Expertiza Refactoring for: review_response_map.rb Model.

path of file: app/models/review_response_map.rb 

Link to deployed project: http://152.46.16.195:5902/

Credentials:
(as an instructor)
username: instructor6
password: password

(as a student)
username: student559
password: password

NOTE: You can view more admins and users after logging in as instructor6 then going to: Manage > Users
And login as any of the users. All the default passwords are 'password'. You may create new users in the same place.


Code improved were based on the criteria given as a requirement as well as a few suggestions and changes from CodeClimate.

Manual Testing Steps:

In order to test the changes made to the ReviewResponseMap, bring up Expertiza and log in as an administrator.  Once logged in, proceed with the following steps:

1.	Create at least three users to perform the tests.
2.	Create an assignment for only the users you just created.  Ensure that the assignment is only available for your new users.  It’s important to follow this step exactly so that you will not confuse your new users with the preexisting users.
3.	Sign out.
4.	Log in to Expertiza as User1 and submit the assignment.
5.	Open two new Chrome Incognito windows and log in as the other two users and select that submission for review.  It’s best to keep these in multiple incognito tabs so that you won’t have to log out and log back in as another user during each step.
6.	Check from User1’s “Your scores” page whether the page is loading correctly prior to the reviews being performed.
7.	Review the assignment from User2’s login.
8.	Ensure that reviews show up on User1’s page.
9.	Repeat steps 6 and 7 for User3.
10.	While logged in as User1, give feedback to User2 and User3.
11.	Change the deadline so that you are able to switch into the “Metareview Phase”.
12.	Repeat the above steps.
13.	Perform the review as User2 (or User3) and ensure that the metareviews are correctly displayed on User1’s page.


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
