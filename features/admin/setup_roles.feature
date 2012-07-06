Feature: Setup new roles
  In order to have differences in access persmissions
  As an administrator
  I want to be able to create roles

Scenario: Setup new roles
  Given I am logged in as admin
  When I open the roles management
  And I create a new role named "test_role"
  Then I see "test_role" in the list of roles