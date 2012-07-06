Feature: Create a team
  In order to work on a team assignment
  As a student
  I want to be able to create a team so that I can invite others to join

Scenario: Create a team
  Given I am participating on a "team_assignment"
  And I am logged in as a "student1"
  When I open assignment "team_assignment"
  And I click on link to manage my team
  And I create a team with name "test_create_team"
  Then I should see "test_create_team" as the team name
