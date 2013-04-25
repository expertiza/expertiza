Feature: Delete permission for a role
  In order to keep up with changing roles
  As an administrator
  I want to be able to delete permission for a role

Scenario: Delete permission for a role
  Given I am logged in as admin
  And I open the permissions management link
  And I create a new permission named "test_permission"
  Then I open the roles management
  And I create a new role named "test_role"
  And I open the "test_role"
  And I add permission "test_permission" to this role
  And I see "test_permission" in the permissions
  When I delete "test_permission" for the role
  Then I should not see "test_permission" in the list of permissions
