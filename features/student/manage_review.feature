Feature: Manage the review as a student
    In order to manage the submitted review
    As a student and participant of a team assignment
    I want to view the submitted review and edit it by filling out and submitting again
    
    @wip
    Background:
        Given I am logged in as a student
        And I move to the "Assignments" page
        And I click the "test_Metareview" link
        Then I click the "Others' work" link
    @wip
    Scenario: View an submitted review
        When I click the "View" link
        Then I should see the details of submitted review

    @wip
    Scenario: Edit an submitted review
        When I click the "Edit" link
        And I fill in the review
        And I click the "Save Review" button
        Then I should see "Profile was successfully updated."
