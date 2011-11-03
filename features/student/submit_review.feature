Feature: Submit a review as a student
  In order to submit a review
  As a student and participant of a team assignment
  I want to fill out the review online and submit it

Scenario: Submit review for an assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_Metareview" link
  When I click the "Others' work" link
    And I click the "Request a new submission to review" button
    And I click the "Begin" link
    And I fill in the review
    And I click the "Save Review" button
  Then I should see "Your response was successfully saved."