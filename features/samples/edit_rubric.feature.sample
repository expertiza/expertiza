Feature: Edit a Rubric as an Admin
  In order to edit a rubric
  As an expertiza admin
  I want to use the edit rubric form in expertiza

Scenario:Edit Rubric
  Given a browser is open to Expertiza with logging edit_a_rubric-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I click on menu "Questionnaires"
  And I click on menu "Edit questionnaire"
  And I fill in the text_field "question_1_txt" with "modified test question 1"
  And I click the "Save review" button
  Then I click the "Back" link
  And I click on menu "View questionnaire"
  And I verify that the page contains the text "modified test question 1"
  And I close the browser