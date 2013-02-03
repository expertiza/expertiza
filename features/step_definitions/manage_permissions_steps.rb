And /^I open the permissions management link$/ do
  find(:xpath, "//a[contains(.,'Permissions')]").click
end

When /^I create a new permission named "(\S+)"$/ do |perm_name|
  click_link 'New permission'
  fill_in 'permission_name', :with => perm_name
  click_button 'Create'
end

And /^I open the "(\S+)"$/ do |rolename|
  click_link rolename
end

And /^I add permission "(\S+)" to this role$/ do |perm_name|
  click_link 'Add Permission'
  select(perm_name, :from => 'roles_permission_permission_id')
  click_button 'Create'
end

When /^I rename the permission "(\S+)" to "(\S+)"$/ do |arg1, arg2|
  
  step("I open the permissions management link")
  click_link arg1
  step('I click on "Edit"')
  fill_in("Name", :with => arg2)
  step('I press "Edit"')
end

Given /^a permission "(\S+)" exists$/ do |permission|
  Permission.create!(:name => permission)
end

When /^I delete "(\S+)" for the role$/ do |perm_name|
  click_link ' Remove'
end

Then /^I should not see "(\S+)" in the list of permissions$/ do |perm_name|
  should have_no_content perm_name
end