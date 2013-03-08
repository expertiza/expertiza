Feature: Manage permissions
    As an administrator
    I want to be able to add, edit, and delete new permissions and add/delete them to roles

    Background: Add a permission
        Given I am logged in as admin
        And I open the permissions management link
        And I create a new permission named "test_permission"
        Then I click on "test_permission"

    Scenario: Edit a permission
        When I click on "Edit"
        And I fill in "Name" with "different_permission"
        And I press "Edit"
        Then I should not see "test_permission"
        And I should see "different_permission"

    Scenario: Delete a permission
        Given I click on "Delete"
        Then I should not see "test_permission"
    
    Scenario: Add permission to role
        Given I open the roles management
        And I create a new role named "test_role"
        And I open the "test_role"
        And I add permission "test_permission" to this role
        Then I should see "test_permission"

    Scenario: Edit a permission for a role
        Given a role "test_role" exists
        When I open the roles management
            And I open the "test_role"
            And I add permission "test_permission" to this role	
        When I rename the permission "test_permission" to "new_permission"
            And I open the roles management
            And I open the "test_role"
        Then I should see "new_permission"
        And I should not see "test_permission"

    Scenario: Delete permission for a role
        Given a role "test_role" exists
        When I open the roles management
            And I open the "test_role"
            And I add permission "test_permission" to this role
            And I should see "test_permission"
            And I delete "test_permission" for the role
        Then I should not see "test_permission" 
