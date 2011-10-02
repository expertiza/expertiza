Feature: Edit start/due date for a topic an Admin
  In order to edit start/due date
  As an expertiza admin
  I want to use the edit topic form in expertiza
  
Scenario: Edit date
  Given a browser is open to Expertiza with logging edit_topic_date-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I edit sign up sheet of first assignment
  And link "Show start/due date" exists
  And I click the "Show start/due date" link
  And I edit text field submission_1 to "2010-12-26 19:44:20"
  And I click the "Save start/due dates" button
  And I click the "Show start/due date" link
  Then I verify that the page contains the text "2010-12-26 19:44:20"
  And I close the browser