When /^I leave the team$/ do
  click_link 'Leave Team'
end

Then /^I should see that I am not in the team$/ do
  should have_content 'You don\'t have a team yet!'
end