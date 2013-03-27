Feature: Create a team assignment and add participants
  In order for students to work on team assignment
  As an admin
  I want to create team assignments and add some students as participants

Scenario: Create a team assignment and add participants
  Given I am participating on a "team_assignment"
  And I am logged in as a "student2"
  Then I should find "team_assignment" under list of assignments