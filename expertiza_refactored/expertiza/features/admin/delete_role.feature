Feature: Delete a role
  If there is a role that is no longer used
  As an administrator
  I want to be able to delete that role

Scenario: Delete a role
  Given I am logged in as admin
  When I open the roles management
  And I create a new role named "test_role"
  And I see "test_role" in the list of roles
  When I delete "test_role"
  Then I should not see "test_role" in the list of roles