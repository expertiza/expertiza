describe 'MentoredTeam' do
  let(:assignment) { create(:assignment) }
  let(:team) { create(:mentored_team, assignment: assignment, parent_id: assignment.id) }
  let(:user) { create(:student) }

  describe '#add_member' do
    before do
      allow(TeamsUser).to receive(:create).and_return(double('TeamsUser'))
    end

    context 'when the parent add_member returns true' do
      it 'assigns a mentor and returns true' do
        allow_any_instance_of(AssignmentTeam).to receive(:add_member).with(user).and_return(true)
        expect(MentorManagement).to receive(:assign_mentor).with(assignment.id, team.id)

        result = team.add_member(user, assignment.id)
        expect(result).to be true
      end
    end

    context 'when the parent add_member returns false' do
      it 'does not assign a mentor and returns false' do
        allow_any_instance_of(AssignmentTeam).to receive(:add_member).with(user).and_return(false)
        expect(MentorManagement).not_to receive(:assign_mentor)

        result = team.add_member(user, assignment.id)
        expect(result).to be false
      end
    end
  end

  describe '#import_team_members' do
    before do
      team
    end

    context 'when all teammates exist and are not already in the team' do
      it 'calls add_member for each user and assigns mentors' do
        user1 = create(:student, name: 'student2064')
        user2 = create(:student, name: 'student2065')
        allow(User).to receive(:find_by).with(name: 'student2064').and_return(user1)
        allow(User).to receive(:find_by).with(name: 'student2065').and_return(user2)
        allow(TeamsUser).to receive(:find_by).and_return(nil)
        allow(team).to receive(:add_member).and_return(true)

        row_hash = { teammembers: ['student2064', 'student2065'] }
        team.import_team_members(row_hash)

        expect(team).to have_received(:add_member).with(user1, team.parent_id)
        expect(team).to have_received(:add_member).with(user2, team.parent_id)
      end
    end

    context 'when a teammate does not exist' do
      it 'raises an ImportError with the appropriate message' do
        allow(User).to receive(:find_by).with(name: 'student2069').and_return(nil)
        row_hash = { teammembers: ['student2069'] }

        expect {
          team.import_team_members(row_hash)
        }.to raise_error(ImportError, /The user 'student2069' was not found/)
      end
    end

    context 'when teammate names are blank' do
      it 'skips blank entries without calling add_member' do
        row_hash = { teammembers: ['', '   '] }
        expect(team).not_to receive(:add_member)
        team.import_team_members(row_hash)
      end
    end
  end
end
