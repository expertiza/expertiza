Feature: Create a Course as an Admin
  In order to create a course
  As an expertiza admin
  I want to use the create course form in expertiza

Scenario: Create Course
	Given I am logged in as admin
	When I click the menu link "Manage..."
	When I click on "Create Public Course"
  		And I fill in "course_name" with "course_name 1"
  		And I fill in "course_directory_path" with "course_directory_path 1"
  		And I fill in "course_info" with "course_info 1"
  		And I click the "Create" button
  	Then I should see "course_name 1"
