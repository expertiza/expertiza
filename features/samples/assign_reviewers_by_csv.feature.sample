Feature: Assign Reviewers by Importing a CSV File
  In order to assign reviewers for an assignment
  As an administive user
  I want to import those assignments via a csv file

Scenario:  Assign Reviewers based on csv file
  Given a browser is open to Expertiza with logging assign_reviewers_by_csv-log.txt
  And I am logged into Expertiza as an Admin
  When I find the popup for ASSIGN_REVIEWERS_COURSE I click on assign reviewers
  Then I can upload a CSV file ASSIGN_REVIEWERS_IMPORT_FILENAME to assign reviewers
  And make sure the reviewers ASSIGN_REVIEWERS_IMPORT_TEAMS are created
  And I close the browser