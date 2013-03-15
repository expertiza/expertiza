Feature: Manage instructors
    In order to have instructors assigned to a course
    As an administrator
    I want to be able to create, edit, and delete users as instructors

    Background: Create an instructor
        Given I am logged in as admin
        When I open instructors management page
        And I create a new instructor named "test_instructor"
        Then I should be able to see "test_instructor" under the list of instructors

    Scenario: Edit an instructor
        Given I open users management page
        When I click on "test_instructor" starting with "t"
        And I edit "test_instructor" to have the name "test_instructor_edit"
        And I open instructors management page
        Then I should be able to see "test_instructor_edit" under the list of instructors

    Scenario: Delete an instructor
        Given I delete the instructor "test_instructor"
        Then I should not be able to see "test_instructor" under the list of instructors
