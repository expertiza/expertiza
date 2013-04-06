When /^I open assignment "(\S+)"$/ do |assignment|
  #click on the team assignment for which team is being created
  click_link 'team_assignment'
end

And /^I create a team with name "(\S+)"$/ do |team_name|
  #fill in team name
  fill_in 'team_name', :with => team_name
  click_button 'Create Team'
end

Then /^I should see "(\S+)" as the team name$/ do |team_name|
  should have_content team_name
end

When /^I invite "(\S+)" to the team "(\S+)/ do |username, teamname|
      pending # steps to invite student to team 
end

Then /^I should see that member "(\S+)" is pending/ do |username|
      pending # steps to see that a member is pending 
end
