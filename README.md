This is forked for course project in CSC517

E1981. Student-generated questions added to rubric
-----

Mentor: Yashad Trivedi (ytrived@ncsu.edu)

The idea:  Instructors make up rubrics in Expertiza. They can ask about anything that is relevant to all the projects that will be submitted. But sometimes students want specific advice on aspects of their work that may be different from the work or topics that other students are working on. It would surely be nice if they could ask reviewers to answer questions specific to their project.

What needs to be done/changed:  In Expertiza, all kinds of rubrics and surveys are subclasses of Questionnaire. A Questionnaire can contain “questions” of several types (e.g., checkboxes, dropdowns, text boxes). You should add a new subclass of Questionnaire called, say, SupplementalReviewQuestionnaire (I know that’s awkward, but I can’t think of anything better).

- An assignment could have a checkbox (on the Review Strategy tab of assignment creation) that, if and when checked, would enable assignment participants to create a supplemental review rubric.  I would suggest putting a button or link on the page that appears when a student clicks on “Your work”.  This button would take the student to the same page that an instructor lands on when creating a new rubric (select “Questionnaires” from the menu at the top, and then, e.g., “New private item” from the “Review” line).  The student could then create a review rubric just like the author does.

- This rubric would be created on behalf of the author. You would have to add a field to the teams table so that the rubric could be stored in an AssignmentTeam. I would suggest that this field be called, supplemental_review_question_id (note the distinction between the class (SupplementalReviewQuestionnaire) and the instance of the questionnaire (SupplementalReviewQuestions)).

- When a reviewer fills out a rubric, the ResponseController should display a set of rubrics, in order, on the same page. This set would normally consist of just a review rubric (a Response object), but in this case the set would have a review rubric and a supplemental review rubric.  That is, there would be two items in the set instead of one. And in general, the ResponseController should be written so that it always iterates through a set of rubrics, though in all other instances, there would be only one element (a single rubric) in this set.

Student View: Then there is the question of how students would see feedback given on such a rubric. The “View” function for a rubric should display answers submitted for the SupplementalReviewQuestionnaire as well as the ReviewQuestionnaire.  And it probably makes sense to add another column to the “View scores” page (for both instructor and students) to report the scores that students gave on these questions (if indeed, any of them were scored questions).  I would not worry about including scores on student-generated questions in the overall score for the (regular) review, since doing so might encourage students to ask “easy” questions so that their reviewers would give them a lot of high scores.

Note: This project has been done twice before.  Here are the links to the project from last fall.
- http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2018/E1879_Student_Generated_Questions_Added_To_Rubric 
- https://github.com/zyczyh/expertiza 
- https://github.com/expertiza/expertiza/pull/1325 
- https://youtu.be/3PUNknSbU-k 

That implementation had several problems.
- Design problems
  - The review rubric is divided into “Regular Review Questions” and “Supplementary [Supplemental] Review Questions.”  There are several issues with this.
    - Rubrics can already be divided into sections (cf. Program 2).  Adding an extra set of headers that no one could get rid of would make the rubric confusing.
    - The method create_supplemental_review_questionnaire is in questionnaires_controller.  This is a bad choice, because it clutters questionnaires_controller.  Make supplemental_review_questionnaire a subclass of Questionnaire or ReviewQuestionnaire, and give it its own create method.
    - There are four tests for whether there is a supplemental review questionnaire.  Checks like this disturb the flow of the method they are in, and mean that anyone who reads that method also has to know about student-generated “questions.”  When the reader of a class has to know about large numbers of extraneous items to understand the code, the code becomes unreadable.
    - It would be really nice if “regular” and supplemental items could be mixed in the same rubric.  This could be done if supplemental questions are assigned a sequence number just like other questions.  Think about how this can cleanly be worked into the design (should Supplemental be a subclass of Question?). 
  - Calculation as to whether an instructor can edit the page is done in controller code; it should be in model code.
  - Messy pull request
    - The pull request did not include the latest refactoring, and indeed, tried to revert several refactorings that were done while the project was in progress.
    - The pull request included the first OSS project of one of the team members (E1850).  This is a show-stopper if we don’t want to merge that first project.

It was also done in Spring 2018. Here is the link to that pull request. Although we rejected this pull request for the reasons below, there may still be some use to reading the code.

- Use "SupplementalReviewQuestionnaire" instead of "srq" will be clearer for later developers.
- In questionnaire_controller.rb Line 372: Questionnaire creation code can use `create` instead. And it is unnecessary to use the instance variable. Also, you can make values as parameters, instead of assigning them one by one.
- There are a couple of DRY violations, but more importantly, response_controller checks in 9(!) places for "supplementary review questions."  Checking more than once or twice is a definite no-no.
- Their tests are shallow - test irrelevant, unlikely-to-fail functionality.

Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.svg?branch=master)](https://travis-ci.org/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/github/expertiza/expertiza/badge.svg?branch=master)](https://coveralls.io/github/expertiza/expertiza?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/f3a41f16c2b6e45aa9d4/maintainability)](https://codeclimate.com/github/expertiza/expertiza/maintainability)

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
