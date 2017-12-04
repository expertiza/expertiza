include TopicHelper
describe "supplementary rubric testing" do
  before(:each) do
    # create assignment and topic
    create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
    create_list(:participant, 3)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).first, team: AssignmentTeam.first)
    create(:topic, topic_name: "TestTopic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_questionnaire)
    create(:questionnaire)
    create(:question)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
  end

  it "has manage rubric button to add/edit supplementary questionnaire" do
    signup_topic
    expect(page).to have_content "Manage Supplementary Rubric"
  end

  it "add supplementary questionnaire to teams model" do
    signup_topic
    click_button "Manage Supplementary Rubric"
    assert !Team.supplementary_rubric_by_team_id(Team.second.id).nil?
  end

  it "should display Supplementary Questionnaire to assigned student" do
    submit_to_topic
    click_button "Manage Supplementary Rubric"
    click_button "Add"
    click_button "Save review questionnaire"
    user = User.find_by(name: "student2066")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    click_link "Begin"
    expect(page).to have_content "Supplementary Reviewee Generated Questions"
  end
end
