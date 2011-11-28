Feature: Change the handle as a user
  In order to change the way I will be known to my reviewers
  As a student and
  As a user of an assignment
  I want to change my handle for current assignment

Scenario: Change my handle for current assignment
  Given I am logged in as a student
   And I move to the "Assignments" page
   And I click the "test_team_invites" link
  When I click the "Change your handle" link
    And I fill in my new handle
    And I click the "Save" button
  Then I should have changed my handle for current assignment