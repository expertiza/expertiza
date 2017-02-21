require 'rails_helper'

describe 'Team' do
  it "verify create team and node for Course Team" do
    course = build(Course)
    course.name = "newCourse"
    course.save
    team = CourseTeam.create_team_and_node(course.id)
    expect(team).to be_kind_of(CourseTeam)
    expect(team.name).to start_with(course.name)
  end

  it "verify create team and node for Assignment Team" do
    assignment = build(Assignment)
    assignment.name = "newAssignment"
    assignment.save
    team = AssignmentTeam.create_team_and_node(assignment.id)
    expect(team).to be_kind_of(AssignmentTeam)
    expect(team.name).to start_with(assignment.name)
  end
end
