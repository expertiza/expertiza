Feature: Submit Work to an Assignment as a User
  In order to submit work to an assignment for others to review
  As a user of an assignment in Expertiza
  I want to submit a link to the assignment for a wiki assignment

Scenario:  Log into Expertiza, Submit a link to an assignment
  Given I am logged in as a student
  And I move to the "Assignments" page
  And I click the "test_submit_assigment" link
  Then I click the "Your work" link
  And I enter the hyperlink "http://www.google.com/mail" for my work
  And I click the "Upload link" button
  Then I should see that the link "http://www.google.com/mail" is present on the page
  