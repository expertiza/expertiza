Feature: Login
  Check whether a particular user can login

  Scenario: Successful Login
    Given I am on the login page
    And I am not logged in
    And a student with the username "student" exists
    When I log in as a "student" with password "password"
    Then I should be logged in as "student"



