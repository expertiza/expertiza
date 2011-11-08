Project E208: Changes to permissions (rereview, etc.)

Contact: Ed Gehringer (efg@ncsu.edu)

Classes:
assignment_controller.rb
sign_up_sheet_controller.rb
student_review_controller.rb
student_task_controller.rb
assignment.rb
views/assignment/_due_dates.html.erb
views/assignment/edit.html.erb
views/student_task/list.html.erb

What it does: In Expertiza, each assignment has a set of due dates. Before each due date
(and between each two due dates), different actions are either possible or not possible.
Currently the set of these actions are …
submission (initial submission of work)
review (initial review of that work)
resubmission
re-review
metareview (sometimes called “review of review”)

What is wrong: It really doesn’t make sense to have separate permissions for submission &
resubmission, or for review and rereview. No instructor has ever created an assignment that
at any time allowed one but not the other. On the other hand, several other kinds of operations
are available in Expertiza, which should have their own permissions, but don’t
signup for a topic
dropping of a topic previously signed up for
teammate review
responding to a survey

How to fix
The point of this task is to remove the unneeded permissions from Expertiza, substituting
submission for resubmission, and review for rereview; and also to add new permissions for
signing up, dropping a topic, performing a teammate review, and responding to a survey. You
should also set up the tables so it is easy to add new permissions later.
Also see https://github.com/expertiza/expertiza/issues/107.
Testing
Submit functional tests that set the permissions, and attempt to perform various operations
(e.g., submission or review) when they are allowed and when they are not allowed.


Team:
Gaurav Maheshwari
Munawira Kotyad
Raghu Gowda

Changes made:

Kindly request the reviewer to search for the string "E-208" or "allowed_id" to view the changes made accross various files.

1) Unneeded permissions such as resubmission_allowed_id and rereview_allowed_id are removed. The functionality of the removed permissions are associated with submission_allowed_id and review_allowed_id permissions. 

2)New permissions such as signing up topic (signup_allowed_id), dropping a topic (drop_allowed_id), performing a teammate review (teammate_review_allowed_id) and responding to a survey (survey_response_allowed_id) are added.

3) Refactoring of entities containing the string "review_of_review" to "metareview".
For example: review_of_review_allowed_id is refactored to metareview_allowed_id.

4) Teammate Review Permission is displayed only for team assignments. 

5) Test cases were developed for the new permissions. The following test cases have been added to the test suite.


Tests Covered:

1)Functional tests to test that the review of others work is not enabled before the submission date and is enabled after submission date.

2)Functional tests to test that the submission is allowed before submission date, and not allowed after submission date.

3)Unit tests to check the validity of entries into the due_date table, having review_allowed_id and submission_allowed id , but no rereview_allowed_id or resubmission_allowed_id. These cases were checked with different values for due dates.

4)Unit tests to check the validity of entries into the participants table, having review and submission permissions but no rereview and resubmission permission.

