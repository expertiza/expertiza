When /^I create a (public|private) assignment named "([^"]*)" using (no due date|review named "[^"]*")$/ do  |public_or_private,assignment_name,review_setting|  
  use_review = false
  review_name = ""
  if review_setting =~ /^no due date$/
    use_review = false
  else
    use_review = true
    ((review_name,),) = review_setting.scan(/^review named \"([^"]*)\"$/)
    Given "I have a public review named \"#{review_name}\""
  end

  When "I follow the \"Manage...\" link as an \"instructor\""
    And "I follow \"Create Public Assignment\""
	And "I fill in \"#{assignment_name}\" for \"Assignment name: \""
    if use_review
      And "I fill in \"2020-01-01 00:00:00\" for \"submit_deadline[due_at]\""
      And "I fill in \"2020-01-02 00:00:00\" for \"review_deadline[due_at]\""
	  And "I select \"#{review_name}\" from \"questionnaires[review]\""
  end
	And "I press \"Save assignment\""
  Then "I should see \"#{assignment_name}\""
end

When /^I add user "([^"]*)" as a participant to assignment "([^"]*)"$/ do |user_name, assignment_name|  
  When "I follow the \"Manage...\" link as an \"instructor\""
    And "I follow \"Manage Assignments\""
	And "I follow \"Add participants\""
	And "I fill in \"#{user_name}\" for \"user_name\""
	And "I press \"Add Participant\""
  Then "I should see \"#{user_name}\""
end

When /^I create a (public|private) assignment named "([^"]*)" with max team size (\d+)$/ do  |public_or_private,assignment_name,team_size|  
  Given "I have a public review named \"test_review\""
    And "I have a public metareview named \"test_metareview\""
  When "I follow the \"Manage...\" link as an \"instructor\""
    And "I follow \"Create Public Assignment\""
    And "I fill in \"#{assignment_name}\" for \"Assignment name: \""
    And "I fill in \"2020-01-01 00:00:00\" for \"submit_deadline[due_at]\""
    And "I fill in \"2020-01-02 00:00:00\" for \"review_deadline[due_at]\""
    And "I fill in \"2020-01-03 00:00:00\" for \"reviewofreview_deadline[due_at]\""
    And "I select \"test_review\" from \"questionnaires[review]\""
    And "I select \"test_metareview\" from \"questionnaires[metareview]\""
    And "I select \"Yes\" from \"teamselect\""
    And "I fill in \"#{team_size}\" for \"assignment_team_count\""
    And "I press \"Save assignment\""
  Then "I should see \"#{assignment_name}\""
end	

When /^I (create|join) a team named "([^"]*)" for the assignment "([^"]*)"$/ do |create_join, team_name,assignment_name|
  When "I follow \"Student_task\""
    And "I follow \"#{assignment_name}\""
    And "I follow \"Your team\""
	if (create_join == 'create')
      And "I fill in \"#{team_name}\" for \"team_name\""
      And "I press \"Create Team\""
	elsif (create_join == 'join')
	  And "I follow \"Accept\""
	end
  Then "I should see \"Team Name: #{team_name}\""
end

When /^I invite the user "([^"]*)" to my team for the assignment "([^"]*)"$/ do |user_name, assignment_name|
  When "I follow \"Student_task\""
    And "I follow \"#{assignment_name}\""
    And "I follow \"Your team\""
    And "I fill in \"#{user_name}\" for \"user_name\""
	  And "I press \"Invite\""
  Then "I should see \"#{user_name}\""
end