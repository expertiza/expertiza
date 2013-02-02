Feature: Suggest a topic
  In order to suggest a topic for assignment
  As a student

Scenario: Suggest a topic for assignment
  Given I am logged in as a student
	And an assignment that allows me to suggest topics exists
	And I click the "test_metareview" link
  When I click the "Suggest a topic" link
    And I fill out the new suggestion form
    And I click the "Submit" button
  Then I should see "Thank you for your suggestion!"

Scenario: Student logs in, opens the assignment & suggests a topic for an individual Media Wiki assignment
  Given I am participating on a "Fringe_Event"
  And I am logged in as a "student2"
  And the assignment "Fringe_Event" allows me to suggest topics
  And I provide the Title & the Description on the following page
  And I click "Submit"
  Then the following page should emit the text "Thank you for your suggestion!"
