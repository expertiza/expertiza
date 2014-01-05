require 'rspec'
require 'spec_helper'

describe 'assignments auto-expand'  do
  it 'auto-expands assignments of all courses',  :js => true, :driver => :selenium do
    visit '/'
    page.should have_content('Reusable learning objects through peer review')
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'expertiza')
    click_button('Login')
    page.should have_content('Manage content')
    page.should_not have_content('CourseTest1') #private course
    click_link('2_2Link')   # expand courses
    page.should have_content('CourseTest1') #private course now visible
    choose('public_radio') # show public and private courses
    page.should_not have_content('CSC/ECE 506, Spring 2011') #public course not visible
    page.should_not have_content('Wiki textbook 2 2011') #its assignment not visible

    click_link('2_2Link')   # expand courses
    page.should have_content('CSC/ECE 506, Spring 2011') #public course now visible
    page.should have_content('Wiki textbook 2 2011') #its assignment auto visible
    page.should have_content('Demo - Spring 2011') #public course now visible
    page.should have_content('Demo - Journal Entry 2') #its assignment auto visible
  end

end
