Feature: Create a Rubric as an Admin
  In order to create a rubric
  As an expertiza admin
  I want to use the create rubric form in expertiza
  
Scenario:Create Rubric
  Given a browser is open to Expertiza with logging create_a_rubric-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I click on menu "Questionnaires"
  And I click on menu "Create Public Review"
  And I fill in the text_field "questionnaire_name" with "test rubric 1"
  And I fill in the text_field "new_question_1_txt" with "test question 1"
  And I click the "Create review" button
  And I verify that the page contains the text "test rubric 1"
  And I close the browser
