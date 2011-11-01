Feature: Create a Sign up Sheet as an Admin
  In order to create a sign up sheet
  As an expertiza admin
  I want to use the sign up sheet form in expertiza
  
Scenario: Create Sign up sheet
  Given a browser is open to Expertiza with logging create_signup_sheet-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And Given that assignment ta1 is listed
  And I create a sign up sheet of first assignment
  And I click the "New topic" link
  And I fill in the text_field "topic_topic_identifier" with "1"
  And I fill in the text_field "topic_topic_name" with "test topic 1"
  And I fill in the text_field "topic_category" with "test category 1"
  And I fill in the text_field "topic_max_choosers" with "2"
  And I click the "Create" button
  Then I verify that the page contains the text "test topic 1"
  And I close the browser

