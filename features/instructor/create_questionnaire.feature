Feature: Create a questionnaire
  For students to review others work
  As an instructor
  I should be able to create questionnaires on which reviews can be based

Scenario: Create a questionnaire
  Given I am logged in as admin
  And I create a review questionnaire called "test_review_questionnaire"
  And I follow "Manage Questionnaires Review Rubrics"
  Then I should see "test_review_questionnaire" under list of questionnaires
  Then show me the page
