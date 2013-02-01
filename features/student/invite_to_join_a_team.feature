Feature: Invite another student to join my team
  In order to work on a team assignment
  As a student
  I want to be able to invite other students to join my team

Scenario: Invite another student to join my team
  Given I am participating on a "team_assignment"
  And I am logged in as a "student1"
  When I open assignment "team_assignment"
  And I click on link to manage my team
  And I create a team with name "test_create_team"
  And I invite "student2" to join my team
  Then I should see "student2" in sent invitations
