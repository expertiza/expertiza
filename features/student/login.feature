Feature: Login
  Check whether a particular user can login

Scenario: Successful Login
  Given I go to the login page
  And a student with the username "student" exists
  When I am logged in as a "student"
  Then I should be logged in as "student"



