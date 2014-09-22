And /^I am participating in an assignment with quiz enabled$/ do
    steps %{
       Given I am participating in team assignment \"my_assignment\"
    }
    a = Assignment.where(name: 'my_assignment', team_assignment:  1).first
   a.require_quiz = true
   a.num_quiz_questions =2

   duedates= DueDate.find_all_by_assignment_id(a.id)
    assert(duedates.count>1)
   duedates.each do |date|
       date.quiz_allowed_id = 3
       date.save
   end
  duedate_try= DueDate.find_by_assignment_id(a.id)
    assert(duedate_try.quiz_allowed_id ==3)
   a.save

end

And /^I create a ([^"]*) question and a ([^"]*) question$/ do |question_type_1, question_type_2|
  steps %{
     When I fill in "new_question_1_txt" with "my #{question_type_1} quiz"
     And I check question "#{question_type_1}" with question number 1
     Then I fill in "new_question_2_txt" with "my #{question_type_2} quiz"
     And I check question "#{question_type_2}" with question number 2
  }
end

And /^I check question "([^"]*)" with question number ([^"]*)$/ do |question_type, num|
  case question_type
    when 'True/False'
       steps %{
         When I choose "question_type_#{num}_type_tf"
         Then I choose "new_choices_1_TF_#{num}_iscorrect_1"
             }
  when 'Essay'
    steps %{
         When I choose "question_type_#{num}_type_essay"
             }
  else
    pending
 end
end

And /^I signed up "(.*?)"/ do |topic|
  t= AssignmentTeam.new
  t.name= "my_team"
  t.parent_id= Assignment.find_by_name('my_assignment').id
  t.advertise_for_partner= 0
  t.save

  tu= TeamsUser.new
  tu.team_id= t.id
  tu.user_id= User.find_by_name('student').id
  tu.save

  su= SignedUpUser.new
  su.creator_id= t.id
  su.topic_id= SignUpTopic.find_by_topic_name('test_topic').id
  su.is_waitlisted= 0
  su.save
end
