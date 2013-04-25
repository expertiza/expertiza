Feature: Edit an instructor
  In order to maintain the instructors
  As an administrator
  I want to be able to edit the attributes of an instructor

Scenario: Edit an instructor
  Given I am logged in as admin
  When I open instructors management page
  And I create a new instructor named "test_instructor"
  And I should be able to see "test_instructor" under the list of instructors
#the step below does not work on expertiza. This is a bug. There is no view that maps to edit.
  And I edit "test_instructor" to have the name "test_instructor_edit"
  Then I should be able to see "test_instructor_edit" under the list of instructors