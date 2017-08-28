describe 'CourseTeam' do
  describe "copy course team to assignment team" do
    it "should allow course team to be copied to assignment team" do
      assignment = build(Assignment)
      assignment.name = "test"
      assignment.save!
      assignment_team = AssignmentTeam.new
      assignment_team.save
      course_team = CourseTeam.new
      course_team.copy(assignment_team.id)
      expect(AssignmentTeam.create_team_and_node(assignment_team.id))
      expect(assignment_team.copy_members(assignment_team.id))
    end
  end
end
