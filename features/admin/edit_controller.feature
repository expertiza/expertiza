Feature: Edit a controller
  In order to maintain the controllers and keep up with changing requirements
  As an administrator
  I want to be able to edit an existing controller

Scenario: Edit a controller
  Given I am logged in as admin
  When I open the controller management
  And I open new controller link
  And I create a built-in controller named "test_controller"
  And I should be able to see "test_controller" under the list of missing controllers
  When I click on the "test_controller"
  And I edit the "test_controller" to change the name to "test_controller_edit"
  Then I should be able to see "test_controller_edit" under the list of missing controllers
