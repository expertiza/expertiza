describe Team do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:participant) { build(:participant, user_id: 1, id: 1) }
  let(:participant2) { build(:participant, user_id: 2, id: 2) }
  let(:participant3) { build(:participant, user_id: 3, id: 3) }
  let(:assignment_with_participants) { build(:assignment, id: 1, name: 'no assignment' , participants: [participant])}
  let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
  let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:team_without_participants) { build(:assignment_team, id: 1, name: 'no team')}
  let(:team) { build(:assignment_team, id: 1, name: 'no team', participants: [participant]) }
  let(:team_with_participants_mapping) { build(:assignment_team, id: 1, name: 'no team with participants mapping', participants: [participant])}
  let(:team_user) { build(:team_user, id: 1, user: user) }
  before(:each) do
    allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_user])
  end
  describe '#participant' do
    it 'gets the participants of current team, by default returns an empty array' do
      expect(team_without_participants.participants).to eq([])
    end
  end

  
  describe '.check_for_existing' do

    context 'when team exists' do
      it 'returns nil' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1, name: 'no name').and_return([])
        expect(Team.check_for_existing(assignment, 'no name', 'Assignment')).to be nil
      end
    end
  end


  describe '.generate_team_name' do
    it 'generates the unused team name' do
      expect(Team.generate_team_name('Assignment')).to eq('Assignment Team_1')
    end
  end


  describe '.import' do
    context 'when row is empty and has_column_names option is not true' do
      it 'raises an ArgumentError' do
        expect { Team.import({}, 1, { has_column_names: 'false' }, AssignmentTeam.new) }
          .to raise_error(ArgumentError, 'Not enough fields on this line.')
      end
    end

    
  end

  describe '.handle_duplicate' do
    context 'when parameterized team is nil' do
      it 'returns team name' do
        expect(Team.handle_duplicate(nil, 'no name', 1, 'replace', CourseTeam.new)).to eq('no name')
      end
    end

  end

end
