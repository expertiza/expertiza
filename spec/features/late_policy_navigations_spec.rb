require_relative './helpers/assignment_creation_helper'

describe 'Navigation scenarios for Late Policies' do
  include AssignmentCreationHelper

  # This block runs before each test to set up the necessary context
  before(:each) do
    @course = create(:course, name: 'Test Course')
    login_as('instructor6')
  end

  # Test case for navigating back from "New Late Policy" to the Assignments tab when accessed directly
  it 'navigates to Assignments tab on the home screen from New Late Policy' do
    visit '/late_policies/new'
    click_link 'Back'
    expect(page).to have_current_path('/student_task/list')
  end

  # Test case for navigating back from "All Late Policies" to the Assignments tab when accessed directly
  it 'navigates to Assignments tab on the home screen from All Late Policies' do
    visit '/late_policies'
    click_link 'Back'
    expect(page).to have_current_path('/student_task/list')
  end
end
