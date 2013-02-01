Feature: Create a Team as a User for an Assignment and add Members
  In order to work on an assignment as a team
  As an expertiza user
  I want to create a team and add other expertiza members

Scenario:  Log into Expertiza, create a team and add members
  Given I am logged in as a student
  And I open assignment "test_create_team"
  And there are other members of expertiza
  When I go to edit my team
  And create a team name and name it "test_team_name"
  And invite some members "admin"
  Then I should see that the members "admin" are pending

