Feature: Manage the questionnaires in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage questionnaires.
  Background:
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I follow the "Manage..." link as an "instructor"
        
  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Metareview
    When I follow "Create Public Metareview"
      And I select "Regular" from "questionnaire_section"
      And I press "Select"
      And I fill in "Name" with "Metareview1"
      And I press "Create metareview"
    Then I should see "Metareview1"
    
  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Author Feedback Review
    When I follow "Create Public Author Feedback"
      And I press "Select"
      And I fill in "Name" with "AuthorFeedback1"
      And I press "Create author feedback"
    Then I should see "AuthorFeedback1"

  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Review Rubric
    When I follow "Create Public Review"
      And I press "Select"
      And I fill in "Name" with "PublicMetareview"
      And I press "Create review"
    Then I should see "PublicMetareview"

  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Teammate Review
    When I follow "Create Public Teammate Review"
      And I press "Select"
      And I fill in "Name" with "TeammateReview1"
      And I press "Create teammate review"
    Then I should see "TeammateReview1"
      
  @instructor
  @manage_questionnaires
  Scenario: Expertiza will allow an instructor to create Public Course Evaluation 
    When I follow "Create Public Course Evaluation"
      And I press "Select"
      And I fill in "Name" with "CourseEval"
      And I press "Create course evaluation"
    Then I should see "CourseEval"
