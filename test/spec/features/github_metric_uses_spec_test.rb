require 'rails_helper'
require_relative 'helpers/assignment_creation_helper'

include AssignmentCreationHelper

describe "assignment creation due dates", js: true do

  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
    create_list(:participant, 3)
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
    create(:assignment_due_date, due_at: (DateTime.now.in_time_zone.in_time_zone + 15))
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone.in_time_zone + 50))
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 1).first)
    create(:team_user, user: User.where(role_id: 1).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 1).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
    @assignment = Assignment.first
    login_as("instructor6")
  end

  it "should show Github data on list_submissions page when 'Use github metrics?' is checked" do
    visit "/assignments/#{@assignment.id}/edit"
    check('Use github metrics?', allow_label_click: true)
    visit "/assignments/list_submissions?id=#{@assignment.id}"
    expect(page).to have_content("Github data")
  end

  it "should not show Github data on list_submissions page when 'Use github metrics?' is unchecked" do
    visit "/assignments/#{@assignment.id}/edit"
    uncheck('Use github metrics?')
    visit "/assignments/list_submissions?id=#{@assignment.id}"
    expect(page).to have_no_content("Github data")
  end

  # TODO: add more tests for setting deadlines
end

