require_relative 'features/helpers/assignment_creation_helper'

describe 'Assignment creation topics tab', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
    assignment = create(:assignment, name: 'assignment for late policy test')
    login_as('instructor6')
    visit "/assignments/#{assignment.id}/edit"
    check('assignment_has_due_dates')
    click_link 'Due Dates'
  end

  # Test for flash error message on new late policy page
  it 'Flash Error Message on New Late Policy Page', js: true do
    assignment = Assignment.where(name: 'assignment for late policy test').first
    create(:topic, assignment_id: assignment.id)
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Due Dates'
    click_link 'New Late Policy'
    fails if
      expect(flash[:error]).to be('Failed to save the assignment: ')
  end
end

# Test for back button interaction on new late policy page
it 'Back Button Interaction on New Late Policy Page', js: true do
  assignment = Assignment.where(name: 'assignment for late policy test').first
  create(:topic, assignment_id: assignment.id)
  visit "/assignments/#{assignment.id}/edit"
  click_link 'Due Dates'
  click_button 'New Late Policy'
  click_button 'Back'
  expect(page).to route_to("/assignments/#{assignment.id}/edit")
end

# Test for back button interaction on new late policy page while creating
it 'Back Button Interaction on New Late Policy Page while creating', js: true do
  assignment = Assignment.where(name: 'assignment for late policy test').first
  create(:topic, assignment_id: assignment.id)
  visit "/assignments/#{assignment.id}/edit"
  click_link 'Due Dates'
  click_button 'New Late Policy'
  fill_in "policy_name", with: 'Test Late Policy'
  fill_in "penalty_per_unit", with: '15'
  fill_in "max_penalty", with: '20'
  click_button 'Create'
  visit "/late_policies"
  click_button 'Back'
  expect(page).to route_to("/assignments/#{assignment.id}/edit")
end
end
