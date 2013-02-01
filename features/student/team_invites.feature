Feature: Team invitations
  In order to work on an assignment as a team
  As a student
  I want to be able to invite and accept invitations for an assignment

Scenario: Invite a student to join my team
  Given I am logged in as a student
  And I am participating on a team assignment
  When I go to manage my team
  And I invite another student to join my team
  Then I should see that student in my sent invitations list

Scenario: Accept an invitation
  Given I am logged in as a student
  And I am participating on a team assignment
  And another student has invited me to their team
  When I go to manage my team
  Then I should see that I have an invite pending
  When I accept the invitation
  Then I should see the person I invited on my team
