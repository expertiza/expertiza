Feature: Create an Assignment as an Admin
  In order to create an assignment
  As an expertiza admin
  I want to use the create assignment form in expertiza
  
Scenario:Create Assignment
  Given a browser is open to Expertiza with logging create_an_assignment-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  Then I click the "Create Public Assignment" link
  And I fill in the text_field "assignment_name" with "test1"
  And I fill in the text_field "assignment_directory_path" with "test1"
  And I fill in the text_field "submit_deadline_due_at" with "2010-12-30 22:32:00"
  And I fill in the text_field "review_deadline_due_at" with "2010-12-31 22:32:00"
  And I fill in the text_field "reviewofreview_deadline_due_at" with "2010-11-30 22:32:00"
  And I click the "Save assignment" button
  Then I verify that the page contains the text "test1"
  And I close the browser
  