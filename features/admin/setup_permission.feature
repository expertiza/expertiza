Feature: Setup permissions
  In order for different roles to different permissions
  As an administrator
  I want to be able to setup permissions

Scenario: Setup permissions
  Given I am logged in as admin
  And I open the permissions management link
  When I create a new permission named "test_permission"
#  Then I see "test_permission" on the list of permissions
#  -- This cannot be implemented because there is a bug in expertiza
#  -- When a permission is added, it does not show up in the page that displays all permissions.
#  -- However, in the drop down which is used while adding permission to a role, this permission is present.