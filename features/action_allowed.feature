Feature: Check Permission
	In order to see if action_allowed is working
	As an instructor
	I should not be able to access Assignments

	Scenario: Check Permission
			Given I am not currently logged in
			When I am on the login page
			And I fill in User Name with "user6"
			And I fill in Password with "password"
			And I press Login
			Then I should see "User: user6"
			And I should be on the managecontent page
			And I click on "Assignments" in the top bar
			And I should not have access to it
			And I should still be on the managecontent page

