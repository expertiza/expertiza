Feature: Manage the questionnaires in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage questionnaires.
   # unable to read new_question_1_txt on page due to javascript and capybara text usage
  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Metareview
    Given an instructor named "instructor1"
    And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
    And I follow "Create Public Metareview"
    And I press "Select"
    And I fill in "questionnaire_name" with "Metareview1"
    And I fill in "qq1" for "new_question_1_txt"
    And I press "Create Metareview"
    Then I should see "Metareview1"

  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Author Feedback Review
    Given an instructor named "instructor1"
    And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
    And I follow "Create Public Author Feedback"
    And I press "Select"
    And I fill in "questionnaire_name" with "AuthorFeedback1"
    And I fill in "Question1" for "new_question_1_txt"
    And I press "Create author feedback"
    Then I should see "AuthorFeedback1"

  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Review Rubric
    Given an instructor named "instructor1"
    And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
    And I follow "Create Public Review"
    And I press "Select"
    And I fill in "questionnaire_name" with "Metareview1"
    And I fill in "Question1" for "new_question_1_txt"
    And I press "Create review"
    Then I should see "Review1"

  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Teammate Review
    Given an instructor named "instructor1"
    And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
    And I follow "Create Public Teammate Review"
    And I press "Select"
    And I fill in "questionnaire_name" with "TeammateReview1"
    And I fill in "Question1" for "new_question_1_txt"
    And I press "Create teammate review"
    Then I should see "TeammateReview1"
