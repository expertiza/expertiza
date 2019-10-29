require "spec_helper"
require 'rspec'
describe "alternate view of reviews" do
    before(:each) do
      assignment1 = create(:assignment, name: "111", directory_path: 'test_assignment')
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
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)
      # sleep(10000)
    end

  def load_alternate
    login_as('student2064')
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "111"

    click_link "111"
    expect(page).to have_content "Submit or Review work for 111"
    expect(page).to have_content "Alternate View"

    click_link "Alternate View"
    expect(page).to have_content "Contributor"
  end

  it "shows the correct alternate view" do
    # Load questionnaire with generic setup
    load_alternate
    expect(page).to have_content "Contributor"
    expect(page).to have_content "Stats"
    expect(page).to have_content "Submitted work"
    expect(page).to have_content "Author Feedback"
    expect(page).to have_content "Teammate Review"
    expect(page).to have_content "Final Score"
    expect(page).to have_content "Range"
    expect(page).to have_content "Average"
    expect(page).to have_content "student2064"

    expect(page).to have_css "a[href='#']", text: 'hide stats' 
    expect(page).to have_css "a[href='#']", text: 'show submission' 
    #expect(page).to have_css "a[href='#']", text: 'show reviews' 
    #page.should have_selector('table tr', text: 'show reviews')
    #find(:xpath, "//tr[contains(.,'show reviews')]/td/a", :text => 'show reviews').click
    #expect(page).to have_content "Writeup"
    end
      #describe "grades/participant", :type => :view do
        #it 'exists' do
          #find(:xpath, "//tr[contains(.,'show reviews')]/td/a", :text => 'show reviews').click
        #end
      #end
end

describe "test for instructor" do
  before (:each) do
    create(:instructor)
    create(:assignment, course: nil, name: 'Test Assignment')
    assignment_id = Assignment.where(name: 'Test Assignment')[0].id
    
    assignment_team = create(:assignment_team)
    
    create(:team_user)
    login_as 'instructor6'
    visit "/grades/view?id=#{assignment_id}"

  end

  it "shows summary report" do
    expect(page).to have_content "Summary report for Test Assignment"
    expect(page).to have_content "Show all teams"
    page.first(:xpath, "//a[contains(@href,'#')]").click

  end


end

describe "test for instructor" do
  before(:each) do
    # assignment and topic
    create(:assignment,
           name: "Test Assignment",
           directory_path: "Test Assignment",
           rounds_of_reviews: 2,
           staggered_deadline: true,
           max_team_size: 1,
           allow_selecting_additional_reviews_after_1st_round: true)
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic_1")
    create(:topic, topic_name: "Topic_2")
    create(:topic, topic_name: "Topic_3")
    assignment_id = Assignment.where(name: 'Test Assignment')[0].id
    # rubric
    create(:questionnaire, name: "TestQuestionnaire1")
    create(:questionnaire, name: "TestQuestionnaire2")
    create(:question, txt: "Question1", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, type: "Criterion")
    create(:question, txt: "Question2", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, type: "Criterion")
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)
    questionnaire_id = ReviewQuestionnaire.first.id.to_s

    # deadline type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    create(:team_user, user: User.where(role_id: 2).first)
      create(:team_user, user: User.where(role_id: 2).second)
      create(:assignment_team)
      create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
      create(:signed_up_team)
      
      create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    visit "response/view2?id=#{questionnaire_id}&&team=1&&round=1&&assignment=#{assignment_id}"
  end

  it "can go to review details" do
    expect(page).to have_content "Toggle navigation"
    expect(page).to have_content "Papers on Expertiza"
    expect(page).to have_content "response"
  end
  
end