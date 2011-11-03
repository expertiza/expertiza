Feature: View scores for an assignment
  In order to view resulting scores
  As a student

Scenario: View my submitted work scores
  Given I am logged in as a student
    And I move to the "Assignments" page
    And I click the "test_Metareview" link
    And I click the "Your scores" link
    And I have a work review with score of "85"
    And I have a work review with score of "66"
    And I have a work review with score of "99"
  When I click the "show reviews" link
  Then I should see the three reviews for my submitted work with corresponding scores

Scenario: View my author feedback scores
  Given I am logged in as a student
    And I move to the "Assignments" page
    And I click the "test_Metareview" link
    And I click the "Your scores" link
    And I have a feedback review with score of "93"
  When I click the "show author feedbacks" link
  Then I should see the author feedback review with corresponding score

Scenario: View my teammate review scores
  Given I am logged in as a student
    And I move to the "Assignments" page
    And I click the "test_Metareview" link
    And I click the "Your scores" link
    And I have a teammate review with score of "100"
    And I have a teammate review with score of "100"
  When I click the "show teammate reviews" link
  Then I should see the two teammate reviews with corresponding scores