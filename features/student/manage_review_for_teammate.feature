Feature: Manage the review for teammates as a student
  In order to manage the submitted review for a teammate
  As a student and participant of a team assignment
  I want to view the submitted review and edit it by filling out and submitting again

Scenario: View an submitted review for a teammate
  Given I am logged in as a student
    And I move to the "Assignments" page
    And I click the "test_Metareview" link
  When I click the "Your team" link
    And I click the "View" link
  Then I should see the details of submitted teammate review

Scenario: Edit an submitted review for a teammate
  Given I am logged in as a student
    And I move to the "Assignments" page
    And I click the "test_Metareview" link
  When I click the "Your team" link
    And I click the "Edit" link
    And I fill in the review
    And I click the "Save review" button
  Then I should see "Profile was successfully updated."
