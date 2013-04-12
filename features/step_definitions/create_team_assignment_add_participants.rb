=begin
  To login as a student,
  go to the login page,
  fill in username and password
  and click on login button

  The method below does this
=end

Given /^I am logged in as a "(\S+)"$/ do |username|
  if(!find_button('Logout').nil?)
    click_button 'Logout'
  end
  step 'I go to the login page'

  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'

  if(!find_link('Accept').nil?)
    click_link 'Accept'
  end

  step "I should be logged in as \"#{username}\""
end

=begin
  This is a method to make sure that the student logged in is
  participating in a team assignment. Follow the steps below to achieve this-

1. Login in as administrator
2. Create a team assignment
3. Add 2 students (with usernames student1, student2) to this assignment
   [This is so that "student1" can invite "student2" and "student2" can accept]]

=end

Given /^I am participating on a "(\S+)"$/ do |assignment|
  step "a team assignment named \"#{assignment}\" exists"
  step "I am on the home page"
  step 'a student with the username "student1" exists'
  step 'a student with the username "student2" exists'
  step "add \"student1\" to this \"#{assignment}\""
  step "add \"student2\" to this \"#{assignment}\""
end

=begin
  1. Create a team assignment with the name "team_assignment"
  2. And add "student1" and "student2" to this assignment
=end
Given /^a team assignment named "(\S+)" exists$/ do |assignment|
  newAssignment = Assignment.new
  newAssignment.name = assignment
  newAssignment.team_count= 2
  newAssignment.allow_suggestions= true
  newAssignment.directory_path = 'test'
  newAssignment.spec_location= 'http://'
  newAssignment.availability_flag=true
  newAssignment.team_assignment=true
  newAssignment.save

  submitDate = DueDate.new
  submitDate.assignment_id= newAssignment.id
  submitDate.deadline_type_id = DeadlineType.find_by_name('submission').id
  submitDate.due_at= '2011-12-30 23:09:15'

  reviewDeadline = DueDate.new
  reviewDeadline.assignment_id= newAssignment.id
  reviewDeadline.deadline_type_id= DeadlineType.find_by_name('review').id
  reviewDeadline.due_at= '2012-12-30 23:09:15'

  dropDeadline = DueDate.new
  dropDeadline.assignment_id= newAssignment.id
  dropDeadline.deadline_type_id= DeadlineType.find_by_name('drop_topic').id
  dropDeadline.due_at= '2012-12-30 23:09:15'
end

Then /^I should see "(\S+)" in the list$/ do |assignment|
   node =  find('.theTable td').node().content()
  if(node.include? assignment)
    assert(true)
  else
    assert(false)
  end
end

=begin
  Add participants on a team assignment
=end

Given /^add "(\S+)" to this "(\S+)"$/ do |username, assignment_name|
  user = User.find_by_name(username)
  assignment = Assignment.find_by_name(assignment_name)

  participant = Participant.new
  participant.user_id= user.id
  participant.parent_id= assignment.id
  participant.submit_allowed= true
  participant.review_allowed= true
  participant.type= "AssignmentParticipant"
  participant.save!

=begin
  find(:xpath, "//a[contains(.,'Assignments')]").click
  find(:xpath, "//a/img[@title='Add participants']/..").click
  fill_in 'user_name', :with => username
  click_button 'Add Participant'
  click_link 'Back'
=end
end

=begin
  Check if the team assignment is seen under the list of assignments
=end

Then /^I should find "(\S+)" under list of assignments$/  do |assignment|
  should have_content assignment
end
