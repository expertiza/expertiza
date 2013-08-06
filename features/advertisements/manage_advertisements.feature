Feature: Manage teammate advertisements

Background:
  Given I am logged in as a student
  Given I am participating in team assignment "my_assignment"
    And I have a team with name "my_team" in assignment "my_assignment"

Scenario: Create an advertisement
  When I click on "Assignments"
  Then I click on "my_assignment"
   And I click on "Your team"
   And I click on "new"
  Then I fill in "Please describe the qualifications you are looking for in a teammate." with "No more than 200 pounds."
   And I press "Create"
  Then I should see "No more than 200 pounds."

Scenario: Edit an advertisement
  Given I have created an advertisement

Scenario: Destroy an advertisement

Scenario: Respond to an advertisement when the team is not full
Scenario: Respond to an advertisement when the team is full

Scenario: Decline join team request

Scenario: Inviting a respondent to join a full team should fail

Scenario: Inviting a respondent to join a non-full team should pass

Scenario: Send multiple requests to join a team should be updated
