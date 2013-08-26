Feature: Sign up for a topic as a student
  In order to sign up for a topic
  As an expertiza user
  I want to use the sign up sheet form in expertiza

Background:
  Given I am participating on a "my_assignment"
  And assignment named "my_assignment" has a topic with name "Cucumber Tests"
  And I am logged in as a "student1"

Scenario: sign up for a topic
  When I choose a topic from the list of topics in the assignment "my_assignment"
  Then The topic I chose must be displayed as my topic

Scenario: drop a topic
  Given I signed up the topic "Cucumber Test"
   When I visit "Signup sheet" page
   Then The topic I chose must be displayed as my topic
   When I deselect the topic I chose
   Then I should not see the topic I chose being displayed as my topic

Scenario: in waiting list
  Given all the slots for "Cucumber Test" have been reserved by other students
   When I also sign up for "Cucumber Test"
   Then I should be in waiting list


