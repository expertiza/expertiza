And /^assignment named "([^"]*)" has a topic with name "([^"]*)"$/ do |assignment, topic|
  st=SignUpTopic.new
  st.topic_name= topic
  st.assignment_id= Assignment.find_by_name(assignment).id
  st.max_choosers= 3
  st.topic_identifier= "#1"
  st.save
end

And /^I have a team with name "([^"]*)" in assignment "([^"]*)"$/ do |my_team, my_assignment|
  t=AssignmentTeam.new
  t.name= my_team
  t.parent_id= Assignment.find_by_name(my_assignment).id
  t.save

  tu=TeamsUser.new
  tu.team_id=t.id
  tu.user_id=User.find_by_name('student').id
  tu.save
end

Given /^I have created an advertisement$/  do
  parent_id= Assignment.find_by_name('my_assignment')
  team= Team.find_by_name_and_parent_id('my_team',parent_id)
  team.advertise_for_partner=1
  team.comments_for_advertisement= "This is my ad."
  team.save

  tu=TeamsUser.new
  tu.team_id=team.id
  tu.user_id=User.find_by_name('student').id
  tu.save
end


Given /^a team named "([^"]*)" has an ad with desired qualification "([^"]*)"$/ do |team, ad|
  t= AssignmentTeam.new
  t.name= team
  t.parent_id= Assignment.find_by_name('my_assignment').id
  t.comments_for_advertisement= ad
  t.advertise_for_partner= 1
  t.save

  s1= User.new
  s1.name= "student1"
  s1.fullname= "student1"
  s1.password= "password"
  s1.role_id= 1
  s1.parent_id= 1
  s1.email= "student1@mailinator.com"
  s1.save

  tu= TeamsUser.new
  tu.team_id= t.id
  tu.user_id= User.find_by_name('student1').id
  tu.save

  su= SignedUpUser.new
  su.creator_id= t.id
  su.topic_id= SignUpTopic.find_by_topic_name('test_topic').id
  su.is_waitlisted= 0
  su.save
end

And /^I click on ad icon$/ do
  find(:xpath,"//a/img[@alt='Advertise for partners']/..").click
end