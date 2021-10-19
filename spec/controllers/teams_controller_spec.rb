describe TeamsController do
  describe "POST #create" do
    context "with an assignment team" do
      it "increases count by 1" do
        expect { create :assignment_team, assignment: @assignment }.to change(Team, :count).by(1)
      end
    end

    context "with a course team" do
      it "increases the count by 1" do
        expect { create :course_team, course: @course }.to change(Team, :count).by(1)
      end
    end

    context "with an assignment team " do
      it "deletes an assignment team" do
        @assignment = create(:assignment)
        @a_team = create(:assignment_team)

        expect { @a_team.delete }.to change(Team, :count).by(-1)
      end
    end

    context "with a course team " do
      it "deletes a course team" do
        @course = create(:course)
        @c_team = create(:course_team)

        expect { @c_team.delete }.to change(Team, :count).by(-1)
      end
    end
  end

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
      # expect(response).to redirect_to list_teams_url(id: course.id, type: :Course)
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
      post :bequeath, id: assignment_team.id
      expect(response).to have_http_status(302)
      # expect(response).to redirect_to list_teams_url(id: assignment.id)
      # assignment_teams = AssignmentTeam.all
      # puts assignment_teams.count
    end
  end
end
