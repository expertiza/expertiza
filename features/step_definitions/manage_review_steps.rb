Given /^I have a (public|private) (review|metareview|author feedback|teammate review|survey|global survey|course evaluation) named "([^"]*)"$/ do |public_or_private,review_type,review_name|
  When "I follow the \"Manage...\" link as an \"instructor\""
    And "I follow \"Create #{public_or_private.capitalize} #{review_type.split.map {|w| w.capitalize}.join ' '}\""
    And "I fill in \"#{review_name}\" for \"questionnaire[name]\""
    And "I press \"Create #{review_type}\""
  Then "I should see \"#{review_name}\""
end

Then /^I should see the details of submitted teammate review$/ do
  should have_content "Teammate Review"
end

Then /^I should see the details of submitted review$/ do
  should have_content "Additional Comment"
end