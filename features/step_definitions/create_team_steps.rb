=begin
And /^I open assignment "([^"]*)"$/ do |test|
  should have_link "Assignments"
  click_link 'Assignments'

  should have_link test
  click_link test
end

And /^there are other members of expertiza$/ do
  User.find(:all, :conditions => ["name = 'admin'"]).should_not be_nil
end

And /^create a team name and name it "([^"]*)"$/ do |team_name|
  should have_link "Your team"
  click_link "Your team"

  should have_button "Create Team"
  fill_in 'team_name', :with => team_name
  click_button "Create Team"
end

And /^invite some members "([^"]*)"$/ do |name|
  should have_button "Invite"
  fill_in 'user_name', :with => name
  click_button "Invite"
end

Then /^I should see that the members "([^"]*)" are pending$/ do |name|
  should have_content name
end
=end