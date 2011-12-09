Feature: Add permission to role
  In order to define a role
  As an administrator
  I want to be able to add permissions to a role

Scenario: Add permission to role
  Given I am logged in as admin
  And I open the permissions management link
  And I create a new permission named "test_permission"
  Then I open the roles management
  And I create a new role named "test_role"
  And I open the "test_role"
  And I add permission "test_permission" to this role
  Then I see "test_permission" in the permissions