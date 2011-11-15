<<<<<<< HEAD
And /^I fill in the new team name "([^"]*)"$/ do |team_name|
  should have_button "Save"
  fill_in 'team_name', :with => team_name
end

Then /^I should see the team name has changed to "([^"]*)"$/ do |team_name|
  should have_content(team_name)
=======
And /^I fill in the new team name "([^"]*)"$/ do |team_name|
  should have_button "Save"
  fill_in 'team_name', :with => team_name
end

Then /^I should see the team name has changed to "([^"]*)"$/ do |team_name|
  should have_content(team_name)
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end