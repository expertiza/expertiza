Feature: Sign up for a topic as a user
  In order to sign up for a topic
  As an expertiza user
  I want to use the sign up sheet form in expertiza

Scenario: signup for a topic
  Given I am logged in as a student
  And Given that assignment test student signup is listed
  Then I click the test student signup link
  Then I click the Signup sheet link
  And I click on signup action
  And I verify that the page contains cancel action
