Given /^I have a (public|private) review named "([^"]*)"$/ do |public_or_private,review_name|
  When "I follow the \"Manage...\" link as an \"instructor\""
    And "I follow \"Create #{public_or_private.capitalize} Review\""
    And "I fill in \"#{review_name}\" for \"questionnaire[name]\""
    And "I press \"Create review\""
  Then "I should see \"#{review_name}\""
end

Then /^I should see the details of submitted teammate review$/ do
  should have_content "Teammate Review"
end

Then /^I should see the details of submitted review$/ do
  should have_content "Additional Comment"
end