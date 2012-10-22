Feature: Leave team
  In order to leave team
  As a student and
  As a member of the team
  I want to quit from the team

Scenario: Leave my team of an assignment
  Given I am participating on a "team_assignment"
  And I am logged in as a "student1"
  When I open assignment "team_assignment"
  And I click on link to manage my team
  And I create a team with name "test_create_team"
  And I should see "test_create_team" as the team name
  When I leave the team
  Then I should see that I am not in the team