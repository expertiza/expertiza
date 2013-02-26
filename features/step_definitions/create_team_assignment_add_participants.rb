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
  When 'I go to the login page'

  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'

  if(!find_link('Accept').nil?)
    click_link 'Accept'
  end

  Then "I should be logged in as \"#{username}\""
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
  And "an assignment named \"#{assignment}\" exists"
  And 'a student with the username "student1" exists'
  And 'a student with the username "student2" exists'
  Then "add \"student1\" to this \"#{assignment}\""
  And "add \"student2\" to this \"#{assignment}\""
end

=begin
  1. Create a team assignment with the name "team_assignment"
  2. And add "student1" and "student2" to this assignment
=end
Given /^an assignment named "(\S+)" exists$/ do |assignment|

  And 'I am logged in as admin'

  find(:xpath, "//a/img[@title='Create Public Assignment']/..").click
  fill_in 'assignment_name', :with => assignment
  #select 'teamselect', :with => 'true'
  second_option_xpath = "//*[@id='teamselect']/option[2]"
  second_option = find(:xpath, second_option_xpath).text
  select(second_option, :from => 'teamselect')

  fill_in 'assignment_team_count', :with => 2
  check 'assignment_allow_suggestions'

  fill_in 'assignment_directory_path', :with => 'test'
  fill_in 'assignment_spec_location', :with => 'http://'

  dateNow = "#{Time.now.year}-#{Time.now.month}-#{Time.now.year} 23:59:59"
  fill_in 'submit_deadline_due_at', :with => '2011-12-30 23:09:15'
  second_option_xpath = "//*[@id='submit_deadline_submission_allowed_id']/option[2]"
    second_option = find(:xpath, second_option_xpath).text
    select(second_option, :from => 'submit_deadline_submission_allowed_id')

    fill_in 'review_deadline_due_at', :with => '2012-12-30 23:09:15'

    second_option_xpath = "//*[@id='submit_deadline_review_allowed_id']/option[2]"
    second_option = find(:xpath, second_option_xpath).text
    select(second_option, :from => 'submit_deadline_review_allowed_id')

  fill_in 'drop_topic_due_at', :with => '2012-12-30 23:09:15'
  click_button 'Save assignment'

end


Given 'I am logged in as admin' do
  When 'I go to the login page'

  fill_in 'login_name', :with => 'admin'
  fill_in 'login_password', :with => 'admin'
  click_button 'Login'

  Then 'I should be logged in as "admin"'
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

Given /^add "(\S+)" to this "(\S+)"$/ do |username, assignment|
  find(:xpath, "//a[contains(.,'Assignments')]").click
  find(:xpath, "//a/img[@title='Add participants']/..").click
  fill_in 'user_name', :with => username
  click_button 'Add Participant'
  click_link 'Back'
end

=begin
  Check if the team assignment is seen under the list of assignments
=end

Then /^I should find "(\S+)" under list of assignments$/  do |assignment|
  should have_content assignment
end
