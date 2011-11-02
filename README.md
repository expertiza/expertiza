We have made the following Changes to the Expertiza custom response system

 1. moved some of the controller related code to the response_controller under the new method
 2. Created a method in response_helper.rb that currently stores the customs questions and returns the questions based on the index parameter
 3. Decreased the amount of code in the view file by using for loops to render similar objects (from 469 lines of code to 300 lines).
 4. Developed some functional tests but there is a glitch and we are working on fixing it.
 5. The previous version contains 2 methods namely custom_response_as_html and custom_response_as_html_2011 in the response.rb file. This contained almost 1400 lines of code. I have reduced atleast 350 lines of code by using for loops, case switches and now the code is more readable and understandable and also the redundant code eliminated.

Expertiza
=========

#### Peer review system

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

Setup
-----

### NCSU VCL image

The expertiza environment is already set up in [NC State's VCL](https://vcl.ncsu.edu) image "Ruby on Rails".
If you have access, this is quickest way to get a development environment running for Expertiza.

If not:

### Tools

 * [Set up git](http://help.github.com/set-up-git-redirect)
 * Install Ruby 1.8.7. (Some plugins/gems we use are not yet 1.9.2 compatible)
   On Linux/OSX, use [rvm](http://beginrescueend.com).
   On Windows, use [RubyInstaller](http://rubyinstaller.org) and [RailsInstaller](http://railsinstaller.org).
 * `gem install bundler` (see [issues on Windows](http://matt-hulse.com/articles/2010/01/30/from-zero-to-rails3-on-windows-in-600-seconds/))

### Dependencies

 * libxslt development libraries [OSX: (already installed?) Ubuntu: `sudo apt-get install libxslt-dev` Fedora: `yum install libxslt-devel` Windows: ?]
 * libmysqlclient [OSX: `brew install mysql` Ubuntu: `sudo apt-get install mysql-server mysql-client libmysqlclient-dev` Fedora: `yum install mysql mysql-server mysql-devel`]
 * (optional) [graphviz](http://www.graphviz.org)
 * bundled gems: `bundle install`
 
 If anything is missing here, please report it in an issue or fix it in a pull request. Thanks!

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
 * Follow the [Ruby Style Guide](http://batsov.com/Programming/Ruby/2011/09/12/ruby-style-guide.html) style for syntax, formatting, and naming

When editing existing files:

 * Keep the existing tabbing (use tabs instead of spaces in files that already use tabs everywhere; otherwise use spaces)
 * Keep the existing line ending style (dos/unix)
 * Follow the Ruby style Guide on code you add or edit, as above

Please do no go crazy changing old code to match these guidelines; it will just create lots of potential merge conflicts.
Applying style guidelines to code you add and modify is good enough. :-)
