require 'spec_helper'

describe 'check topic tab' do
  it 'allows admin access topic tab within manage assignments page' do
    visit '/'
    page.should have_content('Reusable learning objects through peer review')
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    page.should have_content('Manage content')
    click_link('Profile')
    page.should have_content('User Profile Information')
    select('(GMT-10:00) Hawaii', :from => 'user_timezonepref')
    click_button('Save')
    page.should have_content('Profile was successfully updated.')
    visit '/assignments/new?public=0'
    page.should have_content('New Assignment')
    fill_in('assignment_name', :with => 'mytesttopic')
    click_button('Create')
    page.should have_content('Editing Assignment')
    click_link('Topics')
    page.should have_content('Signup sheet')
  end
end