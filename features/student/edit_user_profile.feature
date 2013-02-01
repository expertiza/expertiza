Feature: Edit the user profile as a user
  In order to edit the user's information in user profile
  As a student
  I want to be able to view and edit the profile information

Scenario: Edit the information in my user profile
  Given I am logged in as a student
  When I click the "Profile" link
    And I fill out the user profile information
    And I click the "Save" button
  Then I should see "Profile was successfully updated."
