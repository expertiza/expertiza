require 'spec_helper'

describe 'should check login' do
  it 'login successfully' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'expertiza')
    click_button('Login')
    page.should have_content('Manage Content')
  end
end

describe 'should create assignment' do
  it 'login successfully' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'expertiza')
    click_button('Login')
    page.should have_content('Manage Content')
    visit 'http://localhost:3000/assignments/420/edit/'
    fill_in('assignment_name', :with => 'test_assignment')
    select('test', :from => 'assignment_course_id')
    check('Has topics?')
    check('Available to students?')
    click_button('Save')
    page.should have_content('Assignment was successfully saved.')
  end
end

describe 'should create topic' do
  it 'login successfully' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'expertiza')
    click_button('Login')
    page.should have_content('Manage Content')
    visit 'http://localhost:3000/sign_up_sheet/add_signup_topics?id=420'
    click_link('New topic')
    fill_in('topic_topic_identifier', :with => '1')
    fill_in('topic_topic_name', :with => 'test_topic')
    fill_in('topic_category', :with => 'test_category')
    fill_in('topic_max_choosers', :with => '2')
    click_button('Create')
    page.should have_content('Topic was successfully created.')
  end
end

describe 'login as student' do
  it 'should successfully login' do
    visit '/'
    fill_in('login_name', :with => 'student_1')
    fill_in('login_password', :with => 'password_1')
    click_button('login')
    page.should have_content('Assignments')
  end
end

describe 'signup sheet' do
  it 'should successfully reach signup sheet' do
    visit '/'
    fill_in('login_name', :with => 'student_1')
    fill_in('login_password', :with => 'password_1')
    click_button('login')
    page.should have_content('Assignments')
    click_link('Sample_assignment')
    page.should have_content('Submit or review work for Sample_assignment')
    click_link('Signup sheet')
    page.should have_content('Signup sheet for Sample_assignment, Fall 2013 assignment')
  end
end

describe 'signup sheet reservation' do
  it 'should successfully reserve' do
    visit '/'
    fill_in('login_name', :with => 'student_1')
    fill_in('login_password', :with => 'password_1')
    click_button('login')
    page.should have_content('Assignments')
    click_link('Sample_assignment')
    page.should have_content('Submit or review work for Sample_assignment')
    click_link('Signup sheet')
    page.should have_content('Signup sheet for Sample_assignment, Fall 2013 assignment')
    click_link('test_topic')
    page.should have_content('Topic selected')
  end
end

describe 'signup sheet topic selection' do
  it 'should not be able to select another topic once selected' do
    visit '/'
    fill_in('login_name', :with => 'student_1')
    fill_in('login_password', :with => 'password_1')
    click_button('login')
    page.should have_content('Assignments')
    click_link('Sample_assignment')
    page.should have_content('Submit or review work for Sample_assignment')
    click_link('Signup sheet')
    page.should have_content('Signup sheet for Sample_assignment, Fall 2013 assignment')
    click_link('test_topic')
    click_link('test_topic1')
    page.should have_content('You have already signed up for a topic.')
  end
end