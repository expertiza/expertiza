Feature: Sign up for a topic as a user
  In order to sign up for a topic
  As an expertiza user
  I want to use the sign up sheet form in expertiza

Scenario: signup for a topic
  Given I am participating on a "test_assignment"
  And a topic exists under this assignment
  And I am logged in as a "student1"
  When I choose a topic from the list of topics in the assignment "test_assignment"
  Then The topic I chose must be displayed as my topic



