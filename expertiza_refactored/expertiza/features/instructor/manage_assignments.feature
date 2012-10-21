Feature: Manage the assignments in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage assignments
  
  @instructor
  @manage_assignments
  Scenario: Instructor can create a valid assignment
    Given an instructor named "instructor1"
	  And I am logged in as "instructor1" 
      And I have a public review named "test_review"	  
	When I follow the "Manage..." link as an "instructor"
	  And I follow "Create Public Assignment"
	  And I fill in "Assignment1" for "Assignment name: "
	  And I fill in "2020-01-01 00:00:00" for "submit_deadline[due_at]"
	  And I fill in "2020-01-02 00:00:00" for "review_deadline[due_at]"
	  And I select "test_review" from "questionnaires[review]"
	  And I press "Save assignment"
	Then I should see "Assignment1"

  @instructor
  @manage_assignments
  Scenario: Instructor can create a valid assignment (using step)
    Given an instructor named "instructor1"
	  And I am logged in as "instructor1" 
      And I have a public review named "test_review"	  
	When I create a public assignment named "Assignment2" using review named "test_review"
	Then I should see "Assignment2"

	
  @instructor
  @manage_assignments
  Scenario: Instructor is notified when an assignment with a duplicate name is created
    Given an instructor named "instructor1"
	  And I am logged in as "instructor1" 
      And I have a public review named "test_review"	  
	When I create a public assignment named "duplicate_test" using review named "test_review"
	  And I create a public assignment named "duplicate_test" using review named "test_review"
	Then I should see "There is already an assignment named"
	
  @instructor
  @manage_assignments
  Scenario: Creating an assignment with no due date should fail.
    Given an instructor named "instructor1"
	  And I am logged in as "instructor1"   
	When I create a public assignment named "Assignment3" using no due date
	Then I should not see "Assignment was successfully created."
	
  @instructor
  @manage_assignments
  @too_many
  Scenario: Adding too many students to a team for an assignment should fail.
    Given an instructor named "instructor1"
	  And a student named "student1"
	  And a student named "student2"
	  And a student named "student3"
	  And I am logged in as "instructor1"   
	When I create a public assignment named "Assignment4" with max team size 2
	  And I add user "student1" as a participant to assignment "Assignment4"
	  And I add user "student2" as a participant to assignment "Assignment4"
	  And I add user "student3" as a participant to assignment "Assignment4"
	  And I press "Logout"
	  And I log in as "student1"
	  And I create a team named "team1" for the assignment "Assignment4"
	  And I invite the user "student2" to my team for the assignment "Assignment4"
	  And I invite the user "student3" to my team for the assignment "Assignment4"
	  And I press "Logout"
	  And I log in as "student2"
	  And I join a team named "team1" for the assignment "Assignment4"
	  And I press "Logout"
	  And I log in as "student3"
	  And I join a team named "team1" for the assignment "Assignment4"
	Then I should not see "Leave Team"
	
	
	
	