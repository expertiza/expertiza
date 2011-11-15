Feature: Leave team
  In order to leave team
  As a student and
  As a member of the team
  I want to quit from the team

Scenario: Leave my team of an assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_Metareview" link
  And I click the "Your team" link
  And I click the "Leave Team" link
  Then I should see "You don't have a team yet!"