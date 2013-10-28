Feature: Delete an Assignment as an Admin
  In order to delete an assignment
  As an expertiza admin
  I want to click the delete link for the assignment

Scenario:Delete Assignment
  Given a browser is open to Expertiza with logging delete_an_assignment-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  Then I click the "Delete assignment" link
  And I click the "Yes" link
  And I verify that page does not contain the text "test1"
  And I close the browser
  