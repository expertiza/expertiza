Feature: Team invitations
    In order to work on an assignment as a team
    As a student
    I want to be able to invite and accept invitations for an assignment
    Background:
        Given I am logged in as a student
        And I am participating on a "team_assignment"
        Then I go to manage my team
    Scenario: Invite a student to join my team
        Given I invite another student to join my team
        Then I should see that student in my sent invitations list

    Scenario: Accept an invitation
        Given another student has invited me to their team
        Then I should see that I have an invite pending
        When I accept the invitation
        Then I should see the person I invited on my team
