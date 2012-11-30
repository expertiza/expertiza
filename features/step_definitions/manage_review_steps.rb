Then /^I should see the details of submitted teammate review$/ do
  should have_content "Teammate Review"
end

Then /^I should see the details of submitted review$/ do
  should have_content "Additional Comment"
end