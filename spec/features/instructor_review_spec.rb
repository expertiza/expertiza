describe "peer review testing" do
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

  it "lets instructor perform a review and saves" do
    assignment = Assignment.first
    login_as("instructor6")
    visit "/assignments/list_submissions?id=#{assignment.id}"
    expect(page).to have_content 'Perform review'

    click_link "Perform review"
    fill_in "responses[0][comment]", with: "DRY"
    select 5, from: "responses[0][score]"

    click_button "Save Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "lets instructor view a saved review" do
    assignment = Assignment.first
    login_as("instructor6")
    visit "/assignments/list_submissions?id=#{assignment.id}"
    fill_in "responses[0][comment]", with: "Hello world"
    click_button "Save Review"

    visit "/assignments/list_submissions?id=#{assignment.id}"
    expect(page).to have_content 'View review'

    click_link "View review"
    expect(page).to have_content "Hello world"
  end

  it "lets instructor edit a saved review and saves" do
    assignment = Assignment.first
    login_as("instructor6")
    visit "/assignments/list_submissions?id=#{assignment.id}"
    fill_in "responses[0][comment]", with: "Good job"
    click_button "Save Review"

    visit "/assignments/list_submissions?id=#{assignment.id}"
    expect(page).to have_content 'Edit review'

    click_link "Edit review"
    expect(page).to have_content "Good job"

    fill_in "review[comments]", with: "Excellent work"
    click_link "Save Review"
    expect(page).to have_content "Your response was successfully saved."
  end
end

