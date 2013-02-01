Feature: Manage the users in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage students and TAs.

  Background: 
    Given an instructor named "ed_gehringer"
      And a teaching assistant named "sarah_stihl" created by "ed_gehringer"
      And a student named "tommy_tonka" created by "ed_gehringer"
      And a student named "charlie_chevy" created by "ed_gehringer"
    
  @instructor
  @manage_users
  Scenario: View the list of users
    Given I am logged in as "ed_gehringer"
    When I follow "Users"
    Then I should see "Manage users"
      And I should not see "Permission Denied"
    
  @instructor
  @manage_users
  Scenario: View user using username search
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
    When I View User "tommy_tonka"
    Then I should see "User: tommy_tonka"
      And I should not see "tommy_tonka does not exist."
    
  @instructor
  @manage_users
  Scenario: Search the user list by name
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
    When I Search Users for a "Full name" containing "sti"
    Then I should see "sarah_stihl"
      And I should not see "tommy_tonka"
    
  @instructor
  @manage_users
  Scenario: Create a new student or TA
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
      And I follow "New User"
    When I try to create a "Student" user named "hank_harley"
    Then I should see "Manage users"
      And I should not see "prohibited this user from being saved"
  
  @instructor
  @manage_users
  Scenario: Import a delimited list of users
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
      And I click the "Import Users" link
      And I import a CSV with valid data for 3 new users
    When I View User "zelly_zinger"
    Then I should see "User: zelly_zinger"
      And I should not see "zelly_zinger does not exist."
      
  @instructor
  @manage_users
  Scenario: Import an invalid delimited list of users
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
      And I click the "Import Users" link
    When I import a CSV with invalid data for 3 new users
    Then I should see "Validation failed: Email should look like an email address., Email is invalid"
      And I should see "Validation failed: Name can't be blank"
      And I should see "Not enough items" 
      
  @instructor
  @manage_users
  Scenario: Edit an existing user
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
      And I View User "tommy_tonka"
      And I follow "Edit"
      And I fill in "user[name]" with "tonka_tommy"
    When I press "Edit"
    Then I should see "User: tonka_tommy"
      And I should not see "prohibited this user from being saved"
      
  @instructor
  @manage_users
  Scenario: Delete a user
    Given I am logged in as "ed_gehringer"
      And I follow "Users"
      And I View User "charlie_chevy"
      And I delete the user
    When I View User "charlie_chevy"
    Then I should see "charlie_chevy does not exist."
      And I should not see "User: charlie_chevy"
