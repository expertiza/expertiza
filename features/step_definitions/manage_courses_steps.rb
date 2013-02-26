When /^I follow the "Manage..." link as an "([^"]*)"$/ do |role|
  visit "/menu/manage%20#{role}%20content"
end

Given /^I have a (public|private) course named "([^"]*)"$/ do |public_or_private,course_name|
    When "I follow the \"Manage...\" link as an \"instructor\""
      And "I follow \"Create #{public_or_private.capitalize} Course\""
      And "I fill in \"#{course_name}\" for \"Course Name\""
      And "I fill in \"#{course_name}-directory\" for \"Course Directory\""
      And "I fill in \"A very informational course about information\" for \"Course Information\""
      And "I press \"Create\""
    Then "I should see \"Course1\""
end

