Feature: Delete a permission
  For maintenance of the permission
  As an administrator
  I want to be able to delete unused permissions

Scenario: Delete a permission
  Given I am logged in as admin
  And I open the permissions management link
  When I create a new permission named "test_permission"

#  -- This cannot be implemented because there is a bug in expertiza
#  -- When a permission is added, it does not show up in the page that displays all permissions.
#  -- However, in the drop down which is used while adding permission to a role, this permission is present.