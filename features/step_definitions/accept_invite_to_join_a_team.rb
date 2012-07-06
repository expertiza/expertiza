And /^I see that I have received invitation to join "(\S+)"$/ do |team|
  When 'Another student has invited me to join "#{team}"'
  should have_content team
end

When /^I accept the invitation to join the team$/ do
  click_link 'Accept'
end

And /^I click on link to manage my team$/ do
  find(:xpath, "//a[contains(.,'Your team')]").click
end

=begin
Logout and login as student1.
Invite student2 to join a team.
Login as student2 again.
=end
Given /^Another student has invited me to join "(\S+)"$/ do |team|
  click_button 'Logout'
  Given 'I am logged in as a "student1"'
  When 'I open assignment "team_assignment"'
  And 'I click on link to manage my team'
  And 'I create a team with name "test_create_team"'
  And 'I invite "student2" to join my team'
  click_button 'Logout'
  Then 'I am logged in as a "student2"'
  And 'I open assignment "team_assignment"'
  And 'I click on link to manage my team'
end