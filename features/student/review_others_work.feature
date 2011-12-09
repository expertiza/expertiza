Feature: Review another student's work as a student
  In order to review another student's work
  As a student I have to fill out a review
  and save the review

#  Login as admin
#  Create Review questionnaire
#  create assignment "test assignment"(not a team assignment)
#  Create User1
#  add first user as the participant
#  Create User2
#  add User2 as the participant
#  Assign User1 as the reviewer for User2
#  Logout as admin
#  Log in as User2
#  Click on "test assignment" link
#  Click on "Your work" link
#  Fill in the hyperlink text box and click on Upload Link
#  Logout as User2
#  Login as User1
#  Click on "test assignment" link
#  Click on 'Others Work' link
#  Click on Begin
#  Fill on the review
#  Click on Save Review
#  Then I should see "Your response was successfully saved."


#Scenario: Submit review for an assignment
#  Given I am logged in as a student
#  And I move to the "Assignments" page
#  And I click the "test_Metareview" link
#  When I click the "Others' work" link
#    And I click the "Request a new submission to review" button
#    And I click the "Begin" link
#    And I fill in the review
#    And I click the "Save Review" button
#  Then I should see "Your response was successfully saved."

Scenario: Successfully save a review
  Given I am assigned as a reviewer for an assignment
   And I open that particular assignment and begin review
#  And I click the "Save Review" button
#  Then I should see "Your response was successfully saved"
