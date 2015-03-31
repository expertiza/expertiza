Feature: Open an old review
	In order to see if get_scores is working
	As a user
	I want to be able to open an old review

	Scenario: Open an old review
			Given I am not currently logged in
			When I am on the login page
			And I fill in User Name with "user5072"
			And I fill in Password with "password"
			And I press Login
			Then I should see "User: user5072"
			And I click "Writing assignment 1b, Spring 2013"
			Then I should be on the homework page
			And I click "Others' work"
			Then I should see "Reviews for "Writing assignment 1b, Spring 2013"
			And I click "Review done at --2013-03-01 23:57:55 UTC"
			And I should see "review_43986Link"

