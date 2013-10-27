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

When /^a role "(\S+)" exists$/ do |role|
  Role.create!(:name => role, :description => role)
end

When /^I open the "(\S+)" page$/ do |rolename|
  click_link rolename
end

And /^I edit the role to have name as "(\S+)"$/ do |rolename|
  click_link 'Edit'
  fill_in 'role_name', :with => rolename
  click_button 'Edit'
  click_link 'Back'
end

Then /^I delete "(\S+)"$/ do |rolename|
  click_link rolename
  click_link 'Delete'
end

Then /^I should not see "(\S+)" in the list of roles$/ do |rolename|
  should have_no_content rolename
end