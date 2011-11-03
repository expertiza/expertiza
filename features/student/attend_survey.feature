Feature: Attend a survey
  In order to be will to accept a survey request
  As a student
  I want to attend the survey through email

Scenario: Attend the survey
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_team_invites" link
  And I click the "Take a survey" link to the survey page
  And I fill in my email address
  And I click the "Continue" button
  Then I should have attended the survey
