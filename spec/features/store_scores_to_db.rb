# E1731: Tests to check if total score is getting stored in the local_db_scores database
require 'rails_helper'

describe "Store Scores in DB", type: :feature do
  before(:each) do
      @assignment = create(:assignment, name: "TestAssignment", directory_path: 'test_assignment', rounds_of_reviews: 1)
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
      create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone  1.day)
      create(:topic)
      create(:topic, topic_name: "TestReview")
      create(:team_user, user: User.where(role_id: 2).first)
      create(:team_user, user: User.where(role_id: 2).second)
      create(:assignment_team)
      create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
      create(:signed_up_team)
      create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
      create(:assignment_questionnaire)
      create(:question, weight: 100)
    end

  def load_questionnaire
      login_as('student2064')
      click_link "TestAssignment"
      click_link "Others' work"
      choose "topic_id"
      click_button "Request a new submission to review"
      click_link "Begin"
    end

  def submit_review
      load_questionnaire
      fill_in "responses[0][comment]", with: "Hello World. Sample Review Comment"
      select 5, from: "responses[0][score]"
      click_button "Submit Review"
      Response.find(1).update_attribute('is_submitted', true)
    end

  it "store assignment scores in DB" do
    submit_review
    expect do
      @assignment.store_total_scores
      end.to change { LocalDbScore.count }.by 1
  end
end