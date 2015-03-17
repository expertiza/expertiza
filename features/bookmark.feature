Feature: Bookmark Add
	In order to use expertiza application
	As a student
	I want to be able to add

	Scenario: Adding a new bookmark
			Given I am not currently logged in
			When I am on the login page
			And I fill in Email with "user2"
			And I fill in Password with "1asfsd"
			And I press Login
			And I should see "Manage content"
			And I visit the bookmarks/managing_bookmarks page
			Then I should see "View My Bookmarks"
			And I click on "add_new_bookmark"

			