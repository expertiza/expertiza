When /^I open the controller management$/ do
  find(:xpath, "//a[contains(.,'Controllers / Actions')]").click
end

And /^I open new controller link$/ do
  click_link 'New Controller'
end

And /^I create a built-in controller named "(\S+)"$/ do |controller|
  fill_in 'site_controller_name', :with => controller
  check 'site_controller_builtin'
  click_button 'Create'
end

Then /^I should be able to see "(\S+)" under the list of missing controllers$/ do |controller|
  should have_content controller
end