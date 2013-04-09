Feature: Create a Team as a User for an Assignment and add Members
  In order to work on an assignment as a team
  As an expertiza user
  I want to create a team and add other expertiza members

Scenario:  Log into Expertiza, create a team and add members
  Given I am logged in as a student 
  And I am participating on a "team_assignment"
  And a student with the username "student3" exists
  When I go to manage my team
  And I create a team with name "test_team_name"
  And I invite "student3" to the team "test_team_name"
  Then I should see that member "student3" is pending

