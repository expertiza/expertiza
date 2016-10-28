require 'rails_helper'

describe "HeatMapTest", type: :feature do
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))

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
    #create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
    #create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)
    #create(:response, additional_comment:'Round 1 - Good job', round:1)
    #create(:response, additional_comment:'Round 2 - not so good job', round:2)
  end


  def createReviews
    login_as('student2065')
    expect(page).to have_content "User: student2065"
    expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"

    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"

    fill_in "responses[0][comment]", with: "HelloWorld"
    select 5, from: "responses[0][score]"
    fill_in "review[comments]", with: "Excellent work done!"
    click_button "Submit Review"
    expect(page).to have_content 'Your response was successfully saved.'

  end


  def load_questionnaire

    login_as('student2064')
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"

    click_link "Alternate View"

  end


  it "See reviews" do
    createReviews
    #expect(page).to have_content "Review 1"
    expect(page).to have_content "Your response was successfully saved."
    # 1. click on the button of "Toggles question list"
    # 2. expect to have content of the list of questions
  end

  xit "Loads Heat Map page" do
    # Load data
    load_questionnaire

    expect(page).to have_content "Summary Report for assignment"
  end

  it "Sorts by total review score" do
    createReviews
    click_link "Logout"
    load_questionnaire

    expect(page).to have_content "Review 1"

    # 1. click on the button of "Sorts by total review score"
    # 2. calculate or load the total score for each review
    # 3. check if the total score is sorted and toggled between low-to-high and high-to-low
  end


  xit "Sorts by Avg" do
    load_questionnaire
    # 1. click on the button on "Avg" colon title
    # 2. load the value of Average in each row
    # 3. check if the average score is sorted and toggled between low-to-high and high-to-low
  end

  xit "Sorts by Criterion" do
    load_questionnaire
    # 1. click on the button on "Criterion" colon title
    # 2. check if the criterion is sorted and toggled between low-to-high and high-to-low
  end

  xit "Click on reviews" do
    load_review
    # 1. click each row of different criterion
    # 2. expect to have different content based on the criterion
    # 3. expect to have a specified table for each criterion with comments
  end

end
