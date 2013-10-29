require 'spec_helper'

describe 'user does a review' do

  visit '/'
  page.should have_content('Expertiza')
  page.should have_content('Welcome to Expertiza')
  page.should have_content('Login')
  page.should have_content('User Name')
  page.should have_content('Password')
  fill_in 'login_name', :with => 'saay'
  fill_in 'login_password', :with => 'saay'
  click_button 'Login'

  click_link 'Assignments'

  page.should have_content('Assignment')
  page.should have_content('Course')
  page.should have_content('Topic')
  page.should have_content('Current Stage')
  page.should have_content('Publishing Rights')

  click_link 'New_assign'
  click_link 'Others work'

  #open review/metareview page and give response
end