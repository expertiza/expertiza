Feature: View sign up sheet
  In order to check who had selected the topics
  As an administrator
  I want to be able to check team size by its name

 @wip
  Scenario: topic is selected by a team
    Given I am logged in as admin
    Given an assignment named "Exp" exists
    Given "EXP" assignment has been signed up by a team
    When I open the management content page
    And I click on the link "edit signup sheet" of this assignment "EXP"
    Then I should see Topic name


  Scenario: topic is selected by an individual
    Given I am logged in as admin
    When I open the controller management
    And I open new controller link
    And I create a built-in controller named "test_controller"
    Then I should be able to see "test_controller" under the list of missing controllers