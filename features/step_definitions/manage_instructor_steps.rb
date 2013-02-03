When /^I open instructors management page$/ do
  find(:xpath, "//a[contains(.,'Instructors')]").click
end

When /^I open users management page$/ do
  find(:xpath, "//a[contains(.,'Users')]").click
  should have_content "Manage users"
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

When /^I click on "(\S+)" starting with "(\S+)"$/ do |name, alphabet|
  click_link alphabet
  click_link name
end