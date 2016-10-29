require 'rails_helper'

feature 'Instructor edits advice' do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:questionnaire)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))

  end

  scenario 'clicks on edit advice' do

    login_as("instructor6")
    visit '/advice/edit_advice/1'

    expect(page).to have_content("Edit an existing questionnaire's advice")
  end
end