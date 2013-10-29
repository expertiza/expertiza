And /^I invite "(\S+)" to join my team$/ do |username|
  fill_in 'user_name', :with => username
  click_button 'Invite'
end

Then /^I should see "(\S+)" in sent invitations$/ do |username|
  should have_content username
end