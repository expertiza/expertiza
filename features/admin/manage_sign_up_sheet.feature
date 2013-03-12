Feature: Manage sign up sheets as an admin
    In order to manage a sign up sheet
    As an expertiza admin
    I want to use the sign up sheet form in expertiza

Background:
        Given I am logged in as admin
        And I create a public assignment named "test_assignment" with max team size 2
        And I click on "Manage Assignments"
        Then I should see "test_assignment"

    Scenario: Add a new topic
        Given I click on "Add signup sheet" 
        And I follow "New topic"


