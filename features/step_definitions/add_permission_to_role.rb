And /^I open the "(\S+)"$/ do |rolename|
  click_link rolename
end

And /^I add permission "(\S+)" to this role$/ do |perm_name|
  click_link 'Add Permission'
  select(perm_name, :from => 'roles_permission_permission_id')
  click_button 'Create'
end

Then /^I see "(\S+)" in the permissions$/ do |perm_name|
  should have_content perm_name
end