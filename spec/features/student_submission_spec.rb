require 'rails_helper'
require 'spec_helper'
require 'assignment_setup'

RSpec.feature 'assignment submission when student' do

  active_assignment="FeatureTest"
  expired_assignment="LibraryRailsApp"
  d = Date.parse(Time.now.to_s)
  due_date1=(d >> 1).strftime("%Y-%m-%d %H:%M:00")
  due_date2=(d << 1).strftime("%Y-%m-%d %H:%M:00")

  # Before all block runs once before all the scenarios are tested
  before(:all) do
    # Create active/ongoing assignment
    create_assignment(active_assignment, due_date1)
    # Create expired/finished assignment
    create_assignment(expired_assignment, due_date2)
  end

  # Before each block runs before every scenario
  before(:each) do
    # Login as a student before each scenario
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
  end

  # After all block runs after all the scenarios are tested
  after(:all)do
    # Delete active/ongoing assignment created by the test
    assignment = Assignment.find_by_name(active_assignment)
    assignment.delete
    # Delete expired/finished assignment created by the test
    assignment = Assignment.find_by_name(expired_assignment)
    assignment.delete
  end

  # Scenario to check whether  student is able to login
  scenario 'logins with valid credentials' do
    expect(page).to have_content 'Assignment'
  end

  # Scenario to check whether student is able to submit valid link to an ongoing assignment
  scenario 'submits only valid link to ongoing assignment' do
    click_on active_assignment
    click_on 'Your work'
    fill_in 'submission', :with => 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'
    click_on 'Upload link'
    expect(page).to have_content 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'
  end

  # Scenario to check whether student is not able submit invalid link to an ongoing assignment
  scenario 'submits only invalid link to ongoing assignment' do
    click_on active_assignment
    click_on 'Your work'
    fill_in 'submission', :with => 'http://'
    click_on 'Upload link'
    expect(page).to have_content 'URI is not valid'
  end

  # Scenario to check whether student is able to upload a file to an ongoing assignment
  scenario 'submits only existing file to ongoing assignment' do
    click_on active_assignment
    click_on 'Your work'
    attach_file('uploaded_file', File.absolute_path('./spec/features/student_submission_spec.rb'))
    click_on 'Upload file'
    expect(page).to have_content 'student_submission_spec.rb'
  end

  # Scenario to check whether student is able to upload both : valid link and a file to an ongoing assignment
  scenario 'submits link and file to ongoing assignment' do
    click_on active_assignment
    click_on 'Your work'
    fill_in 'submission', :with => 'http://www.csc.ncsu.edu/faculty/efg/517/f15/assignments'
    click_on 'Upload link'
    attach_file('uploaded_file', File.absolute_path('./spec/features/users_spec.rb'))
    click_on 'Upload file'
    expect(page).to have_content 'http://www.csc.ncsu.edu/faculty/efg/517/f15/assignments'
    expect(page).to have_content 'users_spec.rb'
  end

  # Scenario to check whether student is not able submit valid link to a finished  assignment
  scenario 'submits link for finished assignment' do
    click_on expired_assignment
    click_on 'Your work'
    expect(page).to have_no_button('Upload link')
  end

  # Scenario to check whether student is able upload file to a finished  assignment
  scenario 'submits file for finished assignment' do
    click_on expired_assignment
    click_on 'Your work'
    attach_file('uploaded_file', File.absolute_path('./spec/features/student_submission_spec.rb'))
    click_on 'Upload file'
    expect(page).to have_content 'student_submission_spec.rb'
  end

end