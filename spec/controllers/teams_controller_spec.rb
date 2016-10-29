require 'rails_helper'

describe TeamsController do
    describe "Testing copy functionality - " do
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

            # puts "assignment #{assignment.id}"
            post :inherit, id: assignment.id
            expect(response).to have_http_status(302)
            expect(response).to redirect_to list_teams_url(id: course.id, type: :Course)
        end

        it "test for bequeath" do
            assignment = build(Assignment)
            course = Course.new
            course.name = "newCourse"
            course.save
            assignment.course_id = course.id
            assignment.save

            assignment_team = AssignmentTeam.new
            assignment_team.name = "assignment_team_1"
            assignment_team.parent_id = assignment.id
            assignment_team.save!

            assignment_team = AssignmentTeam.new
            assignment_team.name = "assignment_team_2"
            assignment_team.parent_id = assignment.id
            assignment_team.save!

            assignment_team = AssignmentTeam.new
            assignment_team.name = "assignment_team_3"
            assignment_team.parent_id = assignment.id
            assignment_team.save!

            # puts "assignment #{assignment.id}"
            post :bequeath, id: assignment.id
            expect(response).to have_http_status(302)
            # assignment_teams = AssignmentTeam.all
            # puts assignment_teams.count
        end
    end
end
