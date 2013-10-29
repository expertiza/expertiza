require 'spec_helper'

describe 'admin login' do
  visit '/'
  page.should have_content('Expertiza')
  page.should have_content('Welcome to Expertiza')
  page.should have_content('Login')
  page.should have_content('User Name')
  page.should have_content('Password')
  fill_in 'login_name', :with => 'admin'
  fill_in 'login_password', :with => 'expertiza'
  click_button 'Login'

  page.should have_content('Manage Content')
  page.should have_content('Questionnaires')
  page.should have_content('Courses ')
  page.should have_content('Sort by')
  page.should have_content(' Show public and private items ')

end
