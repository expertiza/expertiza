Feature: Manage teammate advertisements

Background:
  Given I am logged in as a student
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
   Given a team named "test_team" has an ad with desired qualification "I need a teammate."
   When I click on "Assignments"
    And I click on "my_assignment"
    And I click on "Signup sheet"
    And I click on ad icon
   Then I should see "I need a teammate."


  Scenario: Respond to an advertisement when I am on a team
  Given I have a team with name "my_team" in assignment "my_assignment"

Scenario: Decline join team request

Scenario: Inviting a respondent to join a full team should fail

Scenario: Inviting a respondent to join a non-full team should pass

Scenario: Send multiple requests to join a team should be updated
