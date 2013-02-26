Feature: Suggest a topic
  In order to suggest a topic for assignment
  As a student

Scenario: Suggest a topic for assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_Metareview" link
  When I click the "Suggest a topic" link
    And I fill out the new suggestion form
    And I click the "Submit" button
  Then I should see "Thank you for your suggestion!"
