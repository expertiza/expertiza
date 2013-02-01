Feature: Delete an instructor
  In order to maintain the instructors
  As an administrator
  I want to be able to delete an instructor

Scenario: Edit an instructor
  Given I am logged in as admin
  When I open instructors management page
  And I create a new instructor named "test_instructor"
  And I should be able to see "test_instructor" under the list of instructors
  And I delete the instructor "test_instructor"
  Then I should not be able to see "test_instructor" under the list of instructors