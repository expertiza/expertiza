Given /^I have a (public|private) (review|metareview|author feedback|teammate review|survey|global survey|course evaluation) named "([^"]*)"$/ do |public_or_private,review_type,review_name|
  step "I follow the \"Manage...\" link as an \"instructor\""
    step "I follow \"Create #{public_or_private.capitalize} #{review_type.split.map {|w| w.capitalize}.join ' '}\""
    step "I press \"Select\""
    step "I fill in \"#{review_name}\" for \"questionnaire[name]\""
    step "I press \"Create #{review_type}\""
  step "I should see \"#{review_name}\""
end

Then /^I should see the details of submitted teammate review$/ do
  should have_content "Teammate Review"
end

Then /^I should see the details of submitted review$/ do
  should have_content "Additional Comment"
end