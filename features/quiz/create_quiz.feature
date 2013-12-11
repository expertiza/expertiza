Feature: create a quiz as assignment participant
     As an assignment participant, I should be able to create a quiz.
Background:
    Given I am logged in as a student
     And  I am participating in an assignment with quiz enabled
     And  assignment named "my_assignment" has a topic with name "test_topic"
     And  I signed up "test_topic"
Scenario: create a quiz and add questions
    Given I visit the page of "Your work"
     When I click on "Create A Quiz"
     Then I should see "New Quiz"
     When I fill in "Name" with "my test quiz"

      And I create a True/False question and a Essay question
     When I press "Create Quiz"
     Then I should see "Quiz was successfully created"

