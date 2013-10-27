Feature: Add an advice on a Rubric as an Admin
  In order to add advice to a rubric
  As an expertiza admin
  I want to use the edit rubric form in expertiza

Scenario:Add Advice
  Given a browser is open to Expertiza with logging add_an_advice-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I click on menu "Questionnaires"
  And I click on menu "Edit questionnaire"
  And I click the "View advice" button
  And I fill in the text_field "horizontal_6_advice" with "test advice 1"
  And I click the "Save Advice" button
  And I click the "View advice" button
  And I verify that the page contains the text "test advice 1"