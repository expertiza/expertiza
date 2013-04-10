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
	  And I fill in "Assignment1" for "Assignment name: "
      And I fill in "2020-01-01 00:00:00" for "submit_deadline_due_at"
	  And I fill in "2020-01-02 00:00:00" for "review_deadline_due_at"
      And I select "test_review" from "questionnaires[review]"
      And I check "assignment_availability_flag"
	  And I press "Save assignment"
	Then I should see "Assignment1"

  @instructor
  @manage_assignments
  Scenario: Instructor can create a valid assignment (using step)
	When I create a public assignment named "Assignment2" using review named "test_review"
	Then I should see "Assignment2"

	
  @instructor
  @manage_assignments
  Scenario: Instructor is notified when an assignment with a duplicate name is created
	When I create a public assignment named "duplicate_test" using review named "test_review"
	  And I create a public assignment named "duplicate_test" using review named "test_review"
	Then I should see "There is already an assignment named"
	
  @instructor
  @manage_assignments
  Scenario: Creating an assignment with no due date should fail.
	When I create a public assignment named "Assignment3" using no due date
	Then I should not see "Assignment was successfully created."
	
  @instructor
  @manage_assignments
  @too_many
  @wip
  Scenario: Adding too many students to a team for an assignment should fail.
