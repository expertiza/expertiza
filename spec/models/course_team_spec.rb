describe 'CourseTeam' do
  let(:course) { build(:course) }
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

  describe ".import" do
    let(:row) do
      {teammembers: 'none'}
    end
    context "when a course team does not exist with id" do
      it "raises ImportError" do
        course_id = 1
        allow(Course).to receive(:find).with(course_id).and_return(nil)
        error_message = "The course with the id \"" + course_id.to_s + "\" was not found. <a href='/course/new'>Create</a> this course?"
        expect { CourseTeam.import(row, nil, course_id, nil) }.
          to raise_error(ImportError, error_message)
      end
    end

    context "when the course team does not have the required fields" do
      it "raises ArgumentError" do
        expect { CourseTeam.import([], nil, 1, nil) }.
          to raise_error(ArgumentError)
      end
    end

    context "when a course team with the same id already exists" do
      it "gets imported through Team.import" do
        course_id = 1
        options = []
        allow(Course).to receive(:find).with(course_id).and_return(course)
        expect(Team).to receive(:import_helper).with(row, course_id, options, instance_of(CourseTeam))
        CourseTeam.import(row, nil, course_id, options)
      end
    end
  end

end
