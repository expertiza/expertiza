Feature: Manage the assignments in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage assignments
    
  Background: 
    Given an instructor named "instructor1"
    And I am logged in as "instructor1" 
    And I have a public review named "test_review"	  
  @instructor
  @manage_assignments
  Scenario: Instructor can create a valid assignment
	When I follow the "Manage..." link as an "instructor"
	  And I follow "Create Public Assignment"
	  When I fill in "Assignment1" for "Name"
      And I press "Create"
      Then I should see "Assignment was successfully created."
      And I check "Available to students"
      And I fill in "2020/01/01 00:00:00 +0000" for "Submission"
	  And I fill in "2020/01/02 00:00:00 +0000" for "Review"
	When I press "Save"
	Then I should see "Assignment was successfully saved."

  @instructor
  @manage_assignments
  Scenario: Instructor can create a valid assignment (using step)
	When I create a public assignment named "Assignment2" using review named "test_review"
	Then I should see "Assignment was successfully saved."

	
  @instructor
  @manage_assignments

  Scenario: Instructor is notified when an assignment with a duplicate name is created
	When I create a public assignment named "duplicate_test" using review named "test_review"
	  And I create a public assignment named "duplicate_test" using review named "test_review"
	Then I should see "There is already an assignment named"
	
  @instructor
  @manage_assignments
  Scenario: Creating an assignment that is available to students with no due date should fail.
	When I create a public assignment named "Assignment3" using no due date
     And "Available to students" is checked
	Then I should not see "Assignment was successfully created."

  Scenario: Creating an assignment with no due date if not available to student should not fail.


  @instructor
  @manage_assignments
  @too_many
  @wip
  Scenario: Adding too many students to a team for an assignment should fail.
