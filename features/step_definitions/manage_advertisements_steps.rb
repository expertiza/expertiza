And /^I have a team with name "([^"]*)" in assignment "([^"]*)"$/ do |my_team, my_assignment|
  t=Team.new
  t.name= my_team
  t.parent_id= Assignment.find_by_name(my_assignment).id
  t.type= "AssignmentTeam"
  t.save

  tu=TeamsUser.new
  tu.team_id=t.id
  tu.user_id=User.find_by_name('student').id
  tu.save
end
