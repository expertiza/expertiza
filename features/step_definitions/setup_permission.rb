And /^I open the permissions management link$/ do
  find(:xpath, "//a[contains(.,'Permissions')]").click
end

When /^I create a new permission named "(\S+)"$/ do |perm_name|
  click_link 'New permission'
  fill_in 'permission_name', :with => perm_name
  click_button 'Create'
end