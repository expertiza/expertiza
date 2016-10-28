require 'rails_helper'

describe TeamsController do
  it "test for inherit" do
    assignment = build(Assignment)
    course = Course.new
    course.name = "newCourse"
    course.save
    assignment.course_id = course.id
    assignment.save

    course_team = CourseTeam.new
    course_team.name = "course_team_1"
    course_team.parent_id = course.id
    course_team.save!

    course_team = CourseTeam.new
    course_team.name = "course_team_2"
    course_team.parent_id = course.id
    course_team.save!

    course_team = CourseTeam.new
    course_team.name = "course_team_3"
    course_team.parent_id = course.id
    course_team.save!

    puts "assignment #{assignment.id}"
    post :inherit, id: assignment.id

    assignment_teams = AssignmentTeam.all
    puts assignment_teams.count
  end
end
