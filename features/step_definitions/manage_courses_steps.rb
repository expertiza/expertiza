When /^I follow the "Manage..." link as an "([^"]*)"$/ do |role|
  visit "/menu/manage%20#{role}%20content"
end

Given /^I have a (public|private) course named "([^"]*)"$/ do |public_or_private,course_name|
    step "I follow the \"Manage...\" link as an \"instructor\""
      step "I follow \"Create #{public_or_private.capitalize} Course\""
      step "I fill in \"#{course_name}\" for \"Course Name\""
      step "I fill in \"#{course_name}-directory\" for \"Course Directory\""
      step "I fill in \"A very informational course about information\" for \"Course Information\""
      step "I press \"Create\""
    step "I should see \"Course1\""
end

