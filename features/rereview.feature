Feature: Update a review
	In order to see rereview working
	As a user
	I want to be able to update an old review

	Scenario: Doing Rereview
			Given I am not currently logged in
			When I am on the login page
			And I fill in User Name with "user5072"
			And I fill in Password with "password"
			And I press Login
			Then I should see "User: user5072"
			And I click "Writing assignment 1b, Spring 2013"
			Then I should be on the homework page
			And I click "Others' work"
			Then I should see "Continuous integration"
			And I click the "Update" link next to it
			And I should see "New Review for Writing assignment 1b, Spring 2013"

