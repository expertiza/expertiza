# spec/features/assignment_creation_spec.rb

require_relative './helpers/assignment_creation_helper'

describe 'Assignment creation topics tab', js: true do
  include AssignmentCreationHelper

  before(:each) do
    create_deadline_types
    create_courses(3)
    @assignment = create(:assignment, name: 'assignment for late policy test')
    login_as_instructor('instructor6')
    visit_assignment_edit_page(@assignment)
    enable_due_dates
  end

  it 'displays flash error message on New Late Policy Page', js: true do
    assignment = find_assignment_by_name('assignment for late policy test')
    create_topic(assignment)
    visit_assignment_edit_page(assignment)
    navigate_to_due_dates
    navigate_to_new_late_policy
    expect(page).to have_content('Failed to save the assignment:')
  end
  
  it 'navigates back to assignment edit page from New Late Policy Page', js: true do
    assignment = find_assignment_by_name('assignment for late policy test')
    create_topic(assignment)
    visit_assignment_edit_page(assignment)
    navigate_to_due_dates
    navigate_to_new_late_policy
    go_back_to_assignment_edit_page
    expect(page).to have_current_path("/assignments/#{assignment.id}/edit")
  end
  
  it 'navigates back to assignment edit page while creating on New Late Policy Page', js: true do
    assignment = find_assignment_by_name('assignment for late policy test')
    create_topic(assignment)
    visit_assignment_edit_page(assignment)
    navigate_to_due_dates
    navigate_to_new_late_policy
    fill_in_late_policy_details('Test Late Policy', '15', '20')
    create_late_policy
    go_back_to_assignment_edit_page
    expect(page).to have_current_path("/assignments/#{assignment.id}/edit")
  end
end
