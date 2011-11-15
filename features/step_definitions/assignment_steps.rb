Given /^I am participating on a team assignment$/ do
<<<<<<< HEAD
  pending # express the regexp above with the code you wish you had
=======
  should have_link "Assignments"
  click_link 'Assignments'

  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  should have_link "test_team_invites"
  click_link  "test_team_invites"
  should have_link "Your team"
  click_link "Your team"

>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
end
