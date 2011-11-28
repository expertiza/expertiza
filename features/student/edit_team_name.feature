Feature: Edit the team name
  In order to change the name of a team
  As a student and
  As a member of the team
  I want to edit the team name and save the change

Scenario: Edit the name of my team
  Given I am logged in as a student
   And I move to the "Assignments" page
   And I click the "test_Metareview" link
  When I click the "Your team" link
    And I click the "Edit Name" link
    And I fill in the new team name "Test"
    And I click the "Save" button
  Then I should see the team name has changed to "Test"