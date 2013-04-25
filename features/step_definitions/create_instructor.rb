When /^I open instructors management page$/ do
  find(:xpath, "//a[contains(.,'Instructors')]").click
end

And /^I create a new instructor named "(\S+)"$/ do |instructor|
  click_button 'New Instructor'
  fill_in 'user_name', :with => instructor
  fill_in 'user_fullname', :with => instructor
  fill_in 'user_email', :with => "#{instructor}@ncsu.edu"
  fill_in 'user_clear_password', :with => 'password'
  fill_in 'user_clear_password_confirmation', :with => 'password'
  click_button 'Create'
end

Then /^I should be able to see "(\S+)" under the list of instructors$/ do |instructor|
  should have_content instructor
end