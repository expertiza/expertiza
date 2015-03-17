Feature: Visiting bookmarks page
	In order to use expertiza application
	As a student
	I want to be able to navigate

	Scenario: Visit to bookmark page
			Given I am not currently logged in
			When I am on the login page
			And I fill in Email with "user2"
			And I fill in Password with "1asfsd"
			And I press Login
			Then I should see "Manage content"
			When I click on "manage_bookmarks"
			Then I should see "Manage Bookmarks"
			