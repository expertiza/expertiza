require_relative './helpers/assignment_creation_helper'

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

  # it 'Flash Error Message on New Late Policy Page', js: true do
  #   assignment = Assignment.where(name: 'assignment for late policy test').first
  #   create(:topic, assignment_id: assignment.id)
  #   visit "/assignments/#{assignment.id}/edit"
  #   click_link 'Due Dates'
  #   click_link 'New Late Policy'
  #   fails if
  #     expect(flash[:error]).to be('Failed to save the assignment: ')
  #   end
  # end

  it 'Back Button Interaction on New Late Policy Page', js: true do
    assignment = create_assignment_and_topic('assignment for late policy test')
    visit_assignment_due_dates_tab(assignment)
    click_button 'New Late Policy'
    click_button 'Back'
    expect(page).to route_to("/assignments/#{assignment.id}/edit")
  end

  it 'Back Button Interaction on New Late Policy Page while creating', js: true do
    assignment = create_assignment_and_topic('assignment for late policy test')
    visit_assignment_due_dates_tab(assignment)
    click_button 'New Late Policy'
    fill_in_late_policy_form('Test Late Policy', '15', '20')
    click_button 'Create'
    click_button 'Back'
    expect(page).to route_to("/assignments/#{assignment.id}/edit")
  end

  private

  def create_assignment_and_topic(assignment_name)
    assignment = Assignment.where(name: assignment_name).first || create(:assignment, name: assignment_name)
    create(:topic, assignment_id: assignment.id)
    assignment
  end

  def fill_in_late_policy_form(name, penalty_per_unit, max_penalty)
    fill_in 'policy_name', with: name
    fill_in 'penalty_per_unit', with: penalty_per_unit
    fill_in 'max_penalty', with: max_penalty
  end
end
