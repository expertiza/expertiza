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
        And I fill in the form fields:
            |   field                       |        data |
            |   "topic_topic_identifier"    |       "10"    |
            |   "topic_topic_name"          |   "test_topic"  |
            |   "topic_category"            | "test_category" |
            |   "topic_max_choosers"        | "2"         |
        And I press "Create"
        Then I should see "Topic was successfully created"
        And I should see "test_topic"
    Scenario: Edit a topic
        Given the topic "test_topic" for assignment "test_assignment" exists 
        And I click on "Edit signup sheet"
        And I click on "Edit_icon"
        And I fill in the form fields:
            | field | data |
            | "topic_topic_name" | "edited_topic" |
            | "topic_max_choosers" | "5" |
        And I press "Update"
        Then I should see "edited_topic"
        And I should see "5"
        And I should not see "test_topic"
        And I should not see "2"
