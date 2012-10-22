Feature: Submit a review for a teammate as a Student
  In order to submit a review for teammates
  As a student and
  As a member of the team
  I want to fill out the review online and submit it

Scenario: Submit review for a teammate in an assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "UNC TLT demo" link
  When I click the "Your team" link
    And I click the "Review" link
    And I fill in the review
    And I click the "Save Teammate Review" button
  Then I should see "Your response was successfully saved."