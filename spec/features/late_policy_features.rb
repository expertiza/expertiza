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

it 'Back Button Interaction on New Late Policy Page', js: true do
    assignment = Assignment.where(name: 'assignment for late policy test').first
    create(:topic, assignment_id: assignment.id)
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Due Dates'
    click_button 'New Late Policy'
    click_button 'Back'
    expect(page).to route_to("/assignments/#{assignment.id}/edit")
  end
end
