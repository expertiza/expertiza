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
end


Given /^a team named "([^"]*)" has an ad with desired qualities "([^"]*)"$/ do |team, ad|
  t= AssignmentTeam.new
  t.name= team
  t.parent_id= Assignment.find_by_name('my_assignment').id
  t.comments_for_advertisement= ad
  t.advertise_for_partner= 1
  t.save

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

Given /^I sent (a|several) join_team requests? to ad "([^"]*)"$/ do |amount, ad|
  request= JoinTeamRequest.new
  assignment_id= Assignment.find_by_name('my_assignment').id
  participant = Participant.find_by_user_id_and_parent_id(User.find_by_name('student').id, assignment_id)
  request.participant_id= participant.id
  request.team_id= Team.find_by_name_and_parent_id('test_team',assignment_id)
  request.status='P'
  request.save
  if amount== "several"
    #pending
  end
end

And /^the team sent me an invitation$/ do
  assignment_id= Assignment.find_by_name('my_assignment').id
  i= Invitation.new
  i.assignment_id= assignment_id
  i.from_id= User.find_by_name('student1').id
  i.to_id= User.find_by_name('student').id
  i.reply_status= 'W'
  i.save
end

When /^I (decline|accept) the invitation$/ do |decline_or_accept|
  if(decline_or_accept== "decline")
    link= 'Decline'
  else
    link= 'Accept'
  end
  within('table') do
     click_link(link)
  end

end

Given /^student "([^"]*)" sent me (a|several) join_team requests?$/ do |people, amount|
  user = User.find_by_name(people)
  assignment_id= Assignment.find_by_name('my_assignment').id

  participant = Participant.new
  participant.user_id= user.id
  participant.parent_id= assignment_id
  participant.submit_allowed= true
  participant.review_allowed= true
  participant.type= "AssignmentParticipant"
  participant.save

  request= JoinTeamRequest.new
  request.participant_id= participant.id
  request.team_id= Team.find_by_name_and_parent_id('my_team',assignment_id)
  request.status='P'
  request.comments= "I want to join your team."
  request.save

  if (amount== "several")
    request_2= JoinTeamRequest.new
    request_2.participant_id= participant.id
    request_2.team_id= Team.find_by_name_and_parent_id('my_team',assignment_id)
    request_2.status='P'
    request_2.comments= "This is my 2nd request."
    request_2.save
  end
end

But /^my team is full$/ do
  assignment= Assignment.find_by_name('my_assignment')
  assignment.max_team_size= 2
  assignment.save

  parent_id= assignment.id
  t= Team.find_by_name_and_parent_id('my_team',parent_id)
  tu= TeamsUser.new
  tu.team_id= t.id
  tu.user_id= User.find_by_name('student2').id
  tu.save

  participant = Participant.new
  participant.user_id=User.find_by_name('student2').id
  participant.parent_id= parent_id
  participant.submit_allowed= true
  participant.review_allowed= true
  participant.type= "AssignmentParticipant"
  participant.save

  su= SignedUpUser.new
  su.creator_id= t.id
  su.topic_id= SignUpTopic.find_by_topic_name('test_topic').id
  su.is_waitlisted= 0
  su.save
end

And /^my team is not full$/ do
  assignment= Assignment.find_by_name('my_assignment')
  assignment.max_team_size= 200
  assignment.save
end

When /^I visit the page of "([^"]*)"$/ do |page_name|
  steps %{
  When I click on \"Assignments\"
  And I click on \"my_assignment\"
  And I click on \"#{page_name}\"
  }
end

Then /^I should only see the latest request$/ do
  should have_content('This is my 2nd request')
  should_not have_content('I want to join your team')
end