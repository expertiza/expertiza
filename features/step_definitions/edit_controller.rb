When /^I click on the "(\S+)"$/ do |controller|
  click_link controller
end

And /^I edit the "(\S+)" to change the name to "(\S+)"$/ do |old_controller, new_controller|
  click_link 'Edit'
  fill_in 'site_controller_name', :with => new_controller
  click_button 'Edit'
  click_link 'Back'
end