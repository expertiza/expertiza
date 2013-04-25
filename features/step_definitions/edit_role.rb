When /^I open the "(\S+)" page$/ do |rolename|
  click_link rolename
end

And /^I edit the role to have name as "(\S+)"$/ do |rolename|
  click_link 'Edit'
  fill_in 'role_name', :with => rolename
  click_button 'Edit'
  click_link 'Back'
end