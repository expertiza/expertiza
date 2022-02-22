require_relative 'helpers/assignment_creation_helper'

# Begin participant testing
describe 'Assignment creation participants', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    create(:course)
    create(:assignment, name: 'participants Assignment')
    create(:assignment_node)
  end

  it 'check to see if participants can be added' do
    student = create(:student)
    login_as('instructor6')
    assignment_id = Assignment.where(name: 'participants Assignment').first.id
    visit "/participants/list?id=#{assignment_id}&model=Assignment"

    fill_in 'user_name', with: student.name, match: :first
    choose 'user_role_participant', match: :first

    expect do
      click_button 'Add', match: :first
      sleep(1)
    end.to change { Participant.count }.by 1
  end

  it 'should display newly created assignment' do
    participant = create(:participant)
    login_as(participant.name)
    expect(page).to have_content('participants Assignment')
  end
end
