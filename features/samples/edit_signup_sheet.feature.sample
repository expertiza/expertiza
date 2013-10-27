Feature: Edit a Sign up Sheet as an Admin
  In order to edit a sign up sheet
  As an expertiza admin
  I want to use the sign up sheet form in expertiza
  
Scenario: Edit Sign up sheet
  Given a browser is open to Expertiza with logging edit_signup_sheet-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I edit sign up sheet of first assignment
  Then I click the "New topic" link
  And I fill in the text_field "topic_topic_identifier" with "10"
  And I fill in the text_field "topic_topic_name" with "edit test topic 1"
  And I fill in the text_field "topic_category" with "edit test category 1"
  And I fill in the text_field "topic_max_choosers" with "2"
  And I click the "Create" button
  And I verify that the page contains the text "edit test topic 1"
  And I close the browser


