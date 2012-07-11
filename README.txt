CSC 517 - Project 2: E406 - Rework on E219 Refactoring

Team Members:
Americo Rodriguez (arodrig3)
Swetha Surapaneni (ssurapa2)
Sudha Sriram (ssriram)

Link to forked repository:
https://github.com/amrodj/expertiza/tree/E406_refactoring_arodrig3

Branch Name: 
E406_refactoring_arodrig3

Link to Pull Request: 
https://github.com/expertiza/expertiza/pull/204



Description of Changes:

****** COMMIT 1 ********

The following objects have been refactored as part of the CSC517
refactoring project (E406):

/config/environments/development.rb
/app/controllers/password_retrieval_controller.rb
/test/functional/password_retrieval_controller_test.rb
/app/views/password_retrieval/forgotten.html.erb

The motivation for the refactoring was that the password retrieval
controller only had a single method which contained the implementation
details of numerous functionality such as validating the email, resetting
the password, and sending an email.

As it was currently written, it would have been difficult to extend or
modify the functionality such as changing how email is actually sent or
altering the validation of the email address to include more validation steps.

Refactoring has allowed for separation of concerns, enhanced
maintainability, and made the code more extensible. Moreover, development.rb was modified to allow a developer to easily add some some config information which will enable send email capability.


****** COMMIT 2 *********

This commit refactored survey_controller.rb

In general, the assign method was extensive, long, and hard to follow. As
such, we extracted some methods and renamed a few variables for clarity.
It is important to note that as the refactoring was taking place, the team
noticed that this method was not working as designed.

Spefically, a previous refactoring effort to the database failed to correct the implementation details of the assign method. Specifically, the assign method had SQL which referenced a column named type_id. However, this
column was removed with the database refactoring effort as can be seen
in /db/migrate/107_merge_questionnaire_and_type.rb

Now, survey_controller.rb works as designed. Thus, this effort encompassed
both a bug fix and a refactoring effort.
