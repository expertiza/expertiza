And /^I edit "(\S+)" to have the name "(\S+)"$/ do |old_name,new_name|
  click_link 'Edit'
  fill_in 'user_name', :with => new_name
  click_link 'Edit'
end