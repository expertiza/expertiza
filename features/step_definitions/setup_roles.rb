When /^I open the roles management$/ do
  find(:xpath, "//a[contains(.,'Roles')]").click
end

And /^I create a new role named "(\S+)"$/ do |rolename|
  click_link 'New role'
  fill_in 'role_name', :with => rolename
  fill_in 'role_description', :with => 'Testing creation of roles'
  click_button 'Create'
end

Then /^I see "(\S+)" in the list of roles$/ do |rolename|
  should have_content rolename
end