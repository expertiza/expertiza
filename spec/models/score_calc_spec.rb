#E1731: Some preliminary tests. Need to verify if correct. Also need to add more test cases

require 'rails_helper'
# include GradesHelper
describe "Store Scores in DB", type: :feature do
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
  end

  def load_questionnaire
    login_as('student2064')
    #expect(page).to have_content "User: student2063"
    #expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    #expect(page).to have_content "Submit or Review work for TestAssignment"
    #expect(page).to have_content "Others' work"

    click_link "Others' work"
    #expect(page).to have_content 'Reviews for "TestAssignment"'

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"
  end

  def submit_review
    load_questionnaire
    fill_in "responses[0][comment]", with: "Hello World. Sample Review Comment"
    select 5, from: "responses[0][score]"
    click_button "Submit Review"
  end

  it "Store scores of Assignment in DB" do
    submit_review
    post :save_score_in_db, {assignment: :assignment}
    expect(LocalDbScore.where(score: 100)).to exist
  end
end


#  @response_maps = ResponseMap.new
#  @response_maps.id = 123456
#  @response_maps.save!
#  it 'Check if scores stored in db' do
#    @scores = LocalDbScore.new
#    @scores.score_type = "ReviewLocalDBScore"
#    @scores.round = 1
#    @scores.score = 75
#    @scores.response_map_id = 123456
#    @scores.save!
#    expect(LocalDbScore.where(response_map_id: 123456)).to exist
#  end