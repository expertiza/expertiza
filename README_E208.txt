Project E208: Changes to permissions (rereview, etc.)

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

