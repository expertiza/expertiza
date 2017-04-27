require 'rails_helper'

describe 'Team', type: :feature do
  before(:each) do
    # create assignment and topic
    create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
    create_list(:participant, 3)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
  end

  it "verify create team and node for Course Team" do
    course = build(Course)
    course.name = "newCourse"
    course.save
    team = CourseTeam.create_team_and_node(course.id)
    expect(team).to be_kind_of(CourseTeam)
    expect(team.name).to start_with(course.name)
  end

  it "verify create team and node for Assignment Team" do
    assignment = Assignment.find_by(name: "TestAssignment")
    assignment.save
    team = AssignmentTeam.create_team_and_node(assignment.id)
    expect(team).to be_kind_of(AssignmentTeam)
    expect(team.name).to start_with(assignment.name)
  end

  it "verify the first submission is recorded correctly" do
    assignment = Assignment.find_by(name: "TestAssignment")
    assignment.first_sub_teamid = -1
    assignment.save
    team = AssignmentTeam.create_team_and_node(assignment.id)
    user = User.find_by(name: "student2064")
    team.add_member(user, assignment.id)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
    visit '/student_task/list'
    assignment = Assignment.find_by(name: "TestAssignment")
    expect(assignment).to have_attributes(:first_sub_teamid => TeamsUser.team_id(assignment.id, user.id))
    expect(page).to have_xpath("//img[contains(@src, 'firstsubmissionrs.png')]")
  end
end
