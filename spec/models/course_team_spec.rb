describe 'CourseTeam' do
  let(:course_team1) { build(:course_team, id: 1) }
  let(:user2) { build(:student, id: 2) }
  let(:participant) { build(:participant, user: user2) }
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
  describe '#import' do
    context 'when the course does not exist' do
      it 'raises an import error' do
        allow(Course).to receive(:find).with(1).and_return(nil)
        expect{CourseTeam.import({}, 1, nil)}.to raise_error(ImportError)
      end
    end
  end
end
