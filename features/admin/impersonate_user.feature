Feature: Impersonate User
	As an Administrator
	I should be able to impersonate users
	
Scenario: Impersonate a student as an Administrator
 	Given an Administrator named "cucumber" exists
	And a Student named "impersonated_account" created by "cucumber" exists
	When I log in as "cucumber"
	And I click the menu link "Impersonate User"
	And I fill in "user_name" with "impersonated_account"
	When I press "Impersonate"
	Then I should be logged in as "impersonated_account"	
	
Scenario: Impersonate a student that does not exist
	Given an Administrator named "cucumber" exists
	When I log in as "cucumber"
	And I click the menu link "Impersonate User"
	And I fill in "user_name" with "impersonated_account"
	When I press "Impersonate"
	Then I should see "No user exists with the name 'impersonated_account'"