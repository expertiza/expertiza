=begin
Given /^I am participating on a team assignment$/ do
  should have_link "Assignments"
  click_link 'Assignments'

  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  should have_link "test_team_invites"
  click_link  "test_team_invites"
  should have_link "Your team"
  click_link "Your team"

end
=end