<<<<<<< HEAD
And /^I fill out the user profile information$/ do
  should have_button('Save')
  fill_in 'user_clear_password_confirmation', :with => 'password'
=======
And /^I fill out the user profile information$/ do
  should have_button('Save')
  fill_in 'user_clear_password_confirmation', :with => 'password'
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end