Feature: Log Entries
  If I register to login to expertiza
  As a student
  I want to be able to have a log entry

Scenario: Create a new user
  Given I am new to expertiza
  And I am creating new account
  When I create a new account
  And I go to Show Log
  Then I should see an entry in Log List

Scenario: Create a new assignment
  Given I am logged in as a admin
  And I am creating a new assignment
  When I go to Assignments
  And I create a new Assignment
  Then I should see an entry in Log List
