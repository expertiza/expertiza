describe 'CourseTeam' do
  let(:course_team1) { build(:course_team, id: 1, name: 'no team') }
  let(:user2) { build(:student, id: 2, name: 'no name') }
  let(:participant) { build(:participant, user: user2) }
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:team_user) { build(:team_user, id: 1, user: user2) }
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
  describe '#parent_model' do
    it 'returns parent_model' do
      course_team = CourseTeam.new
      expect(course_team.parent_model).to eq('Course')
    end
  end
  describe '#assignment_id' do
    it 'returns nil since this team is not an assignment team' do
      course_team = CourseTeam.new
      expect(course_team.assignment_id).to be_nil
    end
  end
  describe '#prototype' do
    it 'creates a course team' do
      expect(CourseTeam.prototype.class).to eq(CourseTeam) 
    end
  end
  describe '#add_participant' do
    it 'adds a participant to the course when it is not already added' do
      allow(CourseParticipant).to receive(:find_by).with(parent_id: 1, user_id: 2).and_return(nil)
      allow(CourseParticipant).to receive(:create).with(parent_id: 1, user_id: 2, permission_granted: 0).and_return(participant)
      expect(course_team1.add_participant(1, user2)).to eq(participant)
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

  describe '#export' do
    it 'writes to a csv' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1])
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
      expect(CourseTeam.export([], 1, {team_name: 'false'})).to eq([["no team", "no name"]])
    end
  end
  describe '#export_fields' do
    it 'returns a list of headers' do
      expect(CourseTeam.export_fields({team_name: 'false'})).to eq(['Team Name', 'Team members', 'Course Name'])
    end
  end
  describe '#add_member' do
    context 'when the user is already on the team' do
      it 'raises an error' do
        allow(course_team1).to receive(:user?).with(user2).and_return(true)
        expect{course_team1.add_member(user2)}.to raise_error("The user \"no name\" is already a member of the team, \"no team\"")
      end
    end
    context 'when the user is not on the team' do
      it 'creates and returns a participant' do
        node = TeamNode.new
        allow(course_team1).to receive(:user?).with(user2).and_return(false)
        allow(TeamsUser).to receive(:create).with(user_id: 2, team_id: 1).and_return(team_user)
        allow(TeamNode).to receive(:find_by).with(node_object_id: 1).and_return(node)
        allow(course_team1).to receive(:add_participant).with(1, user2).and_return(participant)
        allow(course_team1).to receive(:parent_id).and_return(1)
        expect(course_team1.add_member(user2)).to eq(participant)
      end
    end
  end
end
