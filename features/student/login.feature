Feature: Login
Check whether a particular user can login

Scenario: Successful Login
  Given I am on the login page
  And I am not logged in
  When I log in as a "student" with password "password"
  Then I should be logged in as "student"
