require_relative 'helpers/assignment_creation_helper'

# Begin review strategy tab
describe 'Assignment creation review strategy tab', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    create(:assignment, name: 'public assignment for test')
    @assignment_id = Assignment.where(name: 'public assignment for test').first.id
  end

  it 'auto selects' do
    login_as('instructor6')
    visit "/assignments/#{@assignment_id}/edit"
    find_link('ReviewStrategy').click
    select 'Auto-Selected', from: 'assignment_form_assignment_review_assignment_strategy'
    fill_in 'assignment_form_assignment_review_topic_threshold', with: 3
    fill_in 'assignment_form_assignment_max_reviews_per_submission', with: 10
    click_button 'Save'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      review_assignment_strategy: 'Auto-Selected',
      review_topic_threshold: 3,
      max_reviews_per_submission: 10
    )
  end
end
