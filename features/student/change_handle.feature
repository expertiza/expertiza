Feature: Change the handle as a user
  In order to change the way I will be known to my reviewers
  As a student and
  As a user of an assignment
  I want to change my handle for current assignment

Scenario: Change my handle for current assignment
  Given I am logged in as a student
    And I am participating on assignment "team_assignment"
    And I move to the "Assignments" page
    And I click on "team_assignment"
    And I follow "Change your handle" 
  When I fill in my new handle
    And I click the "Save" button
  Then I should have changed my handle for current assignment
