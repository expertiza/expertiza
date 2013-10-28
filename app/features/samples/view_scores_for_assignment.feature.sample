Feature: View Scores for an Assignment as an Admin
  In order to view scores for an assignment
  As an expertiza admin
  I want to use the view scores page in expertiza

Scenario:View Scores
  Given a browser is open to Expertiza with logging view_scores_assignment-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  Then I click the "View scores" link
  And I verify that the page contains the text "cukeuser" 
  And I close the browser
