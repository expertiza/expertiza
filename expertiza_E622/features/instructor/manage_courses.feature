Feature: Manage the courses in Expertiza
  In order for Expertiza to function
  An instructor
  Should be able to manage courses.
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to create a public course
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
      And I follow "Create Public Course"
      And I fill in "Course1" for "Course Name"
      And I fill in "Course1Directory" for "Course Directory"
      And I fill in "A very informational course about information" for "Course Information"
      And I press "Create"
    Then I should see "Course1"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to create a private course
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
    When I follow the "Manage..." link as an "instructor"
      And I follow "Create Private Course"
      And I fill in "Course1" for "Course Name"
      And I fill in "Course1Directory" for "Course Directory"
      And I fill in "A very informational course about information" for "Course Information"
      And I press "Create"
    Then I should see "Course1"
      And I should see "private"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to copy a course
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I have a public course named "Course1"
    When I follow "Manage Courses"
      And I follow "Copy course"
      And I press "Update"
    Then I should see "Copy of Course1"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to delete a course
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I have a public course named "Course1"
    When I follow "Manage Courses"
      And I follow "Delete course"
    Then I should not see "Course1"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to edit a course
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I have a public course named "Course1"
    When I follow "Manage Courses"
      And I follow "Edit course"
      And I fill in "Updated Course1" for "Course Name"
      And I press "Update"
    Then I should see "Updated Course1"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to make a course private
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I have a public course named "Course1"
    When I follow "Manage Courses"
      And I follow "Make private"
    Then I should see "Course1" 
      And I should see "private"
    
  @instructor
  @manage_courses
  Scenario: Expertiza will allow an instructor to view their courses
    Given an instructor named "instructor1"
      And I am logged in as "instructor1"
      And I have a public course named "Course1"
      And I have a private course named "Course2"
    When I follow "Courses"
    Then I should see "Course1"
      And I should see "Course2"
      And I should see "Directory: Course1-directory"
      And I should see "Directory: Course2-directory"
    
  #@instructor
  #@manage_courses 
  #Scenario: Expertiza will not allow a student to manage courses
  #  Given a student named "stupid"
  #    And I am logged in as "stupid"
  #  When I go to "public/menu/manage/courses"
  #  Then I should be redirected to "notfound"

