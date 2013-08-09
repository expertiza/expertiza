Feature: Manage teammate advertisements

Background:
  Given I am logged in as a student
    And a student with the username "student1" exists
    And a student with the username "student2" exists
  Given I am participating in team assignment "my_assignment"
    And assignment named "my_assignment" has a topic with name "test_topic"

  Scenario: Create an advertisement
  Given I have a team with name "my_team" in assignment "my_assignment"
  When I click on "Assignments"
  Then I click on "my_assignment"
   And I click on "Your team"
   And I click on "new"
  Then I fill in "Please describe the qualifications you are looking for in a teammate." with "No more than 200 pounds."
   And I press "Create"
  Then I should see "No more than 200 pounds."

Scenario: Edit an advertisement
  Given I have a team with name "my_team" in assignment "my_assignment"
  Given I have created an advertisement
   When I click on "Assignments"
    And I click on "my_assignment"
    And I click on "Your team"
   Then I click on "edit"
    And I fill in "Please describe the qualifications you are looking for in a teammate." with "I wanna edit my ad."
    And I press "Update"
   Then I should see "I wanna edit my ad."

Scenario: Destroy an advertisement
  Given I have a team with name "my_team" in assignment "my_assignment"
  Given I have created an advertisement
   When I click on "Assignments"
    And I click on "my_assignment"
    And I click on "Your team"
    And I click on "destroy"
   Then I should not see "This is my ad."

Scenario: Respond to an advertisement when I am not on a team
   Given a team named "test_team" has an ad with desired qualities "I need a teammate."
   When I click on "Assignments"
    And I click on "my_assignment"
    And I click on "Signup sheet"
    And I click on ad icon
   Then I should see "I need a teammate."


Scenario: Respond to an advertisement when I am on a team
  Given I have a team with name "my_team" in assignment "my_assignment"

Scenario: Decline join team request
  Given a team named "test_team" has an ad with desired qualities "I need a teammate."
  Given I sent a join_team request to ad "I need a teammate."
    And the team sent me an invitation
   When I click on "Assignments"
    And I click on "my_assignment"
    And I click on "Your team"
   When I decline the invitation
   Then I should not see "student1"

Scenario: Inviting a respondent to join a full team should fail
  Given I have a team with name "my_team" in assignment "my_assignment"
    And I have created an advertisement
  Given student "student1" sent me a join_team request
    But my team is full
   When I visit the page of "Your team"
   Then I should see "I want to join your team."
   When I press "Invite"
   Then I should see "The maximum number in the team is 2. You cannot invite more members."

Scenario: Inviting a respondent to join a non-full team should pass
  Given I have a team with name "my_team" in assignment "my_assignment"
    And I have created an advertisement
  Given student "student1" sent me a join_team request
    And my team is not full
   When I visit the page of "Your team"
   Then I should see "I want to join your team."
   When I press "Invite"
   Then I should see "Waiting for reply"

Scenario: Send multiple requests to join a team should be updated
  Given I have a team with name "my_team" in assignment "my_assignment"
    And I have created an advertisement
   When student "student1" sent me several join_team requests
    And I visit the page of "Your team"
   Then I should only see the latest request
