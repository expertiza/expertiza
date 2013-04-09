When /^I create a (public|private) assignment named "([^"]*)" using (no due date|review named "[^"]*")$/ do  |public_or_private,assignment_name,review_setting|  
  use_review = false
  review_name = ""
  if review_setting =~ /^no due date$/
    use_review = false
  else
    use_review = true
    ((review_name,),) = review_setting.scan(/^review named \"([^"]*)\"$/)
    step "I have a public review named \"#{review_name}\""
  end

  step "I follow the \"Manage...\" link as an \"instructor\""
    step "I follow \"Create Public Assignment\""
	step "I fill in \"#{assignment_name}\" for \"Assignment name\""
	
  if use_review
    step "I fill in \"2020-01-01 00:00:00\" for \"submit_deadline[due_at]\""
    step "I fill in \"2020-01-02 00:00:00\" for \"review_deadline[due_at]\""
	  step "I select \"#{review_name}\" from \"questionnaires[review]\""
	  
  	step "I press \"Save assignment\""
  end

end

When /^I add user "([^"]*)" as a participant to assignment "([^"]*)"$/ do |user_name, assignment_name|  
  step "I follow the \"Manage...\" link as an \"instructor\""
    step "I follow \"Manage Assignments\""
	step "I follow \"Add participants\""
	step "I fill in \"#{user_name}\" for \"user_name\""
	step "I press \"Add Participant\""
  step "I should see \"#{user_name}\""
end

When /^I create a (public|private) assignment named "([^"]*)" with max team size (\d+)$/ do  |public_or_private,assignment_name,team_size|  
  step "I have a public review named \"test_review\""
    step "I have a public metareview named \"test_metareview\""
  step "I follow the \"Manage...\" link as an \"instructor\""
    step "I follow \"Create Public Assignment\""
    step "I fill in \"#{assignment_name}\" for \"Assignment name: \""
    step "I fill in \"2020-01-01 00:00:00\" for \"submit_deadline[due_at]\""
    step "I fill in \"2020-01-02 00:00:00\" for \"review_deadline[due_at]\""
    step "I fill in \"2020-01-03 00:00:00\" for \"reviewofreview_deadline[due_at]\""
    step "I select \"test_review\" from \"questionnaires[review]\""
    step "I select \"test_metareview\" from \"questionnaires[metareview]\""
    step "I select \"Yes\" from \"teamselect\""
    step "I fill in \"#{team_size}\" for \"assignment_team_count\""
    step "I press \"Save assignment\""
  step "I should see \"#{assignment_name}\""
end	

When /^I (create|join) a team named "([^"]*)" for the assignment "([^"]*)"$/ do |create_join, team_name,assignment_name|
  step "I follow \"Student_task\""
    step "I follow \"#{assignment_name}\""
    step "I follow \"Your team\""
	if (create_join == 'create')
      step "I fill in \"#{team_name}\" for \"team_name\""
      step "I press \"Create Team\""
	elsif (create_join == 'join')
	  step "I follow \"Accept\""
	end
  step "I should see \"Team Name: #{team_name}\""
end

When /^I invite the user "([^"]*)" to my team for the assignment "([^"]*)"$/ do |user_name, assignment_name|
  step "I follow \"Student_task\""
    step "I follow \"#{assignment_name}\""
    step "I follow \"Your team\""
    step "I fill in \"#{user_name}\" for \"user_name\""
	  step "I press \"Invite\""
  step "I should see \"#{user_name}\""
end
