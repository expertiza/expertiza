<<<<<<< HEAD
<<<<<<< HEAD
And /^I fill in my new handle$/ do
  should have_button "Save"
  fill_in 'participant_handle', :with => 'test'
end

Then /^I should have changed my handle for current assignment$/ do
  should have_content('Click the activity you wish to perform on the assignment titled')
=======
And /^I fill in my new handle$/ do
  should have_button "Save"
  fill_in 'participant_handle', :with => 'test'
end

Then /^I should have changed my handle for current assignment$/ do
  should have_content('Click the activity you wish to perform on the assignment titled')
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
And /^I fill in my new handle$/ do
  should have_button "Save"
  fill_in 'participant_handle', :with => 'test'
end

Then /^I should have changed my handle for current assignment$/ do
  should have_content('Click the activity you wish to perform on the assignment titled')
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end