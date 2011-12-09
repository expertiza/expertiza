Feature: Edit a role
  In order to change the parameters of a role
  As an administrator
  I should be able to edit the attributes of a role

Scenario: Edit a role
  Given I am logged in as admin
  When I open the roles management
  And I create a new role named "test_role"
  And I see "test_role" in the list of roles
  When I open the "test_role" page
  And I edit the role to have name as "test_role_edit"
  Then I see "test_role_edit" in the list of roles
