Feature: Create a Course as an Admin
  In order to create a course
  As an expertiza admin
  I want to use the create course form in expertiza

Scenario: Create Course
  Given a browser is open to Expertiza with logging create_a_course-log.txt
  And I am logged into Expertiza as an Admin
  And I navigate to the ASSIGNMENT_LIST
  And I Create a public course
  When I fill in the text_field "course_name" with "course_name 1"
  And I fill in the text_field "course_directory_path" with "course_directory_path 1"
  And I fill in the text_field "course_info" with "course_info 1"
  And I click the "Create" button
  And I verify that the page contains the text "course_name 1"
  And I close the browser