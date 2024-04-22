require_relative './helpers/assignment_creation_helper'

describe 'Assignment creation topics tab' do
  include AssignmentCreationHelper
  # This block runs before each test to set up the environment
  before(:each) do
    setup_assignment_test_environment
  end

  # Test to ensure no flash error message is displayed on the New Late Policy Page
  it 'does not displays flash error message on New Late Policy Page' do
    create(:topic, assignment_id: @assignment.id)
    visit "/assignments/#{@assignment.id}/edit"
    click_link 'Due dates'
    click_link 'New late policy'
    expected_error_message = "Failed to save the assignment: #{@assignment.id}"
    expect(page).not_to have_content(expected_error_message)
  end

  # Test to check navigation back to the assignment edit page via the "Back" button
  it 'navigates back to assignment edit page on Back button click' do
    create(:topic, assignment_id: @assignment.id)
    visit "/assignments/#{@assignment.id}/edit"
    click_link 'Due dates'
    click_link 'New late policy'
    click_link 'Back'
    expect(page).to have_current_path("/assignments/#{@assignment.id}/edit")
  end

  # Test to check navigation back to the assignment edit page while creating a late policy
  it 'navigates back to assignment edit page while creating on Back button click' do
    create(:topic, assignment_id: @assignment.id)
    visit "/assignments/#{@assignment.id}/edit"
    click_link 'Due dates'
    click_link 'New late policy'
    fill_in 'late_policy_policy_name', with: 'Test Late Policy'
    fill_in 'late_policy_penalty_per_unit', with: '15'
    fill_in 'late_policy_max_penalty', with: '20'
    click_button 'Create'
    visit '/late_policies'
    click_link 'Back'
    expect(page).to have_current_path("/assignments/#{@assignment.id}/edit")
  end

  private

  def setup_assignment_test_environment
    create_deadline_types
    (1..3).each { |i| create(:course, name: "Course #{i}") }
    @assignment = create(:assignment, name: 'assignment for late policy test')
    login_as('instructor6')
    visit "/assignments/#{@assignment.id}/edit"
    check('assignment_form_assignment_calculate_penalty', allow_label_click: true)
    click_link 'Due dates'
  end

end
