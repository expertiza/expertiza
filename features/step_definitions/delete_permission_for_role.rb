When /^I delete "(\S+)" for the role$/ do |perm_name|
  click_link ' Remove'
end

Then /^I should not see "(\S+)" in the list of permissions$/ do |perm_name|
  should have_no_content perm_name
end