# spec/features/assignment_creation_spec.rb

module AssignmentCreationHelper
  def create_deadline_types
    # Implement creating deadline types
  end
  
  def create_courses(count)
    count.times do |i|
      create(:course, name: "Course #{i + 1}")
    end
  end
  
  def login_as_instructor(username)
    # Implement login functionality
  end
  
  def visit_assignment_edit_page(assignment)
    visit "/assignments/#{assignment.id}/edit"
  end
  
  def enable_due_dates
    check('assignment_has_due_dates')
  end
  
  def find_assignment_by_name(name)
    Assignment.find_by(name: name)
  end
  
  def create_topic(assignment)
    create(:topic, assignment_id: assignment.id)
  end
  
  def navigate_to_due_dates
    click_link 'Due Dates'
  end
  
  def navigate_to_new_late_policy
    click_link 'New Late Policy'
  end
  
  def go_back_to_assignment_edit_page
    click_button 'Back'
  end
  
  def fill_in_late_policy_details(name, penalty_per_unit, max_penalty)
    fill_in "policy_name", with: name
    fill_in "penalty_per_unit", with: penalty_per_unit
    fill_in "max_penalty", with: max_penalty
  end
  
  def create_late_policy
    click_button 'Create'
  end
end

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
