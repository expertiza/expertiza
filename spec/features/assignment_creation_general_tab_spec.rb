require_relative 'helpers/assignment_creation_helper'

# adding test for general tab
describe 'Assignment creation general tab', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
    create(:assignment, name: 'edit assignment for test')

    assignment = Assignment.where(name: 'edit assignment for test').first
    login_as('instructor6')
    visit "/assignments/#{assignment.id}/edit"
    click_link 'General'
  end

  it 'should edit assignment available to students' do
    fill_assignment_form
    check('assignment_form_assignment_microtask')
    check('assignment_form_assignment_is_calibrated')
    click_button 'Save'
    assignment = Assignment.where(name: 'edit assignment for test').first
    expect(assignment).to have_attributes(
      name: 'edit assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory1',
      spec_location: 'testLocation1',
      microtask: true,
      is_calibrated: true
    )
  end

  it 'should edit quiz number available to students' do
    fill_assignment_form
    check('assignment_form_assignment_require_quiz')
    click_button 'Save'
    fill_in 'assignment_form_assignment_num_quiz_questions', with: 5
    click_button 'Save'
    assignment = Assignment.where(name: 'edit assignment for test').first
    expect(assignment).to have_attributes(
      name: 'edit assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory1',
      spec_location: 'testLocation1',
      num_quiz_questions: 5,
      require_quiz: true
    )
  end

  it 'should edit number of members per team ' do
    fill_assignment_form
    check('assignment_form_assignment_show_teammate_reviews')
    fill_in 'assignment_form_assignment_max_team_size', with: 5
    click_button 'Save'
    assignment = Assignment.where(name: 'edit assignment for test').first
    expect(assignment).to have_attributes(
      name: 'edit assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory1',
      spec_location: 'testLocation1',
      max_team_size: 5,
      show_teammate_reviews: true
    )
  end

  ##### test reviews visible to all other reviewers ######
  it 'should edit review visible to all other reviewers' do
    fill_assignment_form
    check 'assignment_form_assignment_reviews_visible_to_all'
    click_button 'Save'
    assignment = Assignment.where(name: 'edit assignment for test').first
    expect(assignment).to have_attributes(
      name: 'edit assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory1',
      spec_location: 'testLocation1'
    )
  end

  it 'check if checking calibration shows the tab' do
    uncheck 'assignment_form_assignment_is_calibrated'
    click_button 'Save'

    check 'assignment_form_assignment_is_calibrated'
    click_button 'Save'

    expect(page).to have_selector('#Calibration')
  end
end
