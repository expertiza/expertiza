Feature: Submit Metareview as a Student
  In order to submit a metareview
  As a student and participant of an assignment
  I want to fill out the metareview online and submit it

Scenario:  Submit Metareview for an assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_Metareview" link
  Then I click the "Others' work" link
  Then I click to begin the metareview
  And I fill in the metareview
  And I click the "Save Metareview" button
  Then I click the "Continue" link
  Then I click the "View" link
  And I verify that the metareview was saved
