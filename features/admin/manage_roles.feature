Feature: Manage User Roles
  In order to have different in access permissions
  As an administrator
  I want to be able to manage users of different roles types

Background: Setup new roles
  Given I am logged in as admin
  When I open the roles management
  And I create a new role named "test_role"
  And I see "test_role" in the list of roles
  Then I open the "test_role" page

Scenario: Edit a role
  Given I edit the role to have name as "test_role_edit"
  Then I see "test_role_edit" in the list of roles

Scenario: Delete a role
  Given I delete "test_role"
  Then I should not see "test_role" in the list of roles
