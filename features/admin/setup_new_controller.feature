Feature: Setup new controller
  In order to achieve different functionality
  As an administrator
  I want to be able to configure new controller

Scenario: Setup new controller
  Given I am logged in as admin
  When I open the controller management
  And I open new controller link
  And I create a built-in controller named "test_controller"
  Then I should be able to see "test_controller" under the list of missing controllers



