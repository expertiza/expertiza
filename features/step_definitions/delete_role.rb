Then /^I delete "(\S+)"$/ do |rolename|
  click_link rolename
  click_link 'Delete'
end

Then /^I should not see "(\S+)" in the list of roles$/ do |rolename|
  should have_no_content rolename
end