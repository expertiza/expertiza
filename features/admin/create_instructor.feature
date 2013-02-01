Feature: Create an instructor
  In order to have instructors assigned to a course
  As an administrator
  I want to be able to create users as instructors

Scenario: Create an instructor
  Given I am logged in as admin
  When I open instructors management page
  And I create a new instructor named "test_instructor"
  Then I should be able to see "test_instructor" under the list of instructors