Given /^the topic "([^"]*)" for assignment "([^"]*)" exists$/ do |arg1, arg2|
    steps %{ 
        Given I click on "Add signup sheet"
        And I follow "New topic"
        And I fill in "topic_topic_identifier" with "10"
        And I fill in "topic_topic_name" with "#{arg1}"
        And I fill in "topic_category" with "test_category"
        And I fill in "topic_max_choosers" with "2"
        And I press "Create"
        And I click on "Manage Assignments"
    } 
end
