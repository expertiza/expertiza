require 'spec_helper'


describe 'admin profile' do
  it 'shows the admin profile page' do
    visit '/'
    #save_and_open_page
    page.should have_content('Reusable learning objects through peer review')
    #Now login as new admin
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    page.should have_content('Manage content')
    click_link('Profile')
    page.should have_content('User Profile Information')
  end
end



describe 'admin timezone' do
  it 'allows change of time zone' do
    visit '/'
    #save_and_open_page
    page.should have_content('Reusable learning objects through peer review')
    #Now login as new admin
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    page.should have_content('Manage content')
    click_link('Profile')
    page.should have_content('User Profile Information')
    select('(GMT-10:00) Hawaii', :from => 'user_timezonepref')
    click_button('Save')
    page.should have_content('Profile was successfully updated.')
  end
end
