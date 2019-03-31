describe TeamsUser do
  # Write your mocked object here!
  let(:participant) { build(:participant, user_id: 1) }
  let(:user) { build(:student, id: 1, name: 'user name', fullname: 'user name', participants: [participant], parent_id: 1) }
  let(:team) { build(:assignment_team, id: 1, name: 'assignment team', users: [], parent_id: 1) }
  let(:team_user) { build(:team_user, id: 1, user: user) }

  describe '#name' do
    it 'determines user name based on the ip address' do
      teams_user = TeamsUser.new
      teams_user.user = user
      expect(teams_user.name(nil)).to eq(user.name)
    end
  end

  describe '#delete' do
    it 'destroys the self team user object' do
      allow(TeamUserNode).to receive(:find_by).with(node_object_id: 1).and_return(TeamUserNode.new)
      expect(TeamUserNode).to receive(:find_by).with(node_object_id: 1)
      expect(team_user.destroy)
      team_user.delete
    end
  end


  describe '#remove_team' do
    context 'when team user is found' do
      it 'removes entry in the TeamUsers table for the given user and given team id' do
        allow(TeamsUser).to receive(:find_by).with(user_id: user.id, team_id: team.id).and_return(team_user)
        expect(team_user.destroy)
        TeamsUser.remove_team(user.id, team.id)
      end
    end

    context 'when team user is not found' do
      it 'does not remove entry in the TeamUsers table for the given user and given team id' do
        allow(TeamsUser).to receive(:find_by).with(user_id: user.id, team_id: team.id).and_return(nil)
        expect(TeamsUser).to_not receive(:destroy)
        TeamsUser.remove_team(user.id, team.id)
      end
    end
  end

  describe '#first_by_team_id' do
    context 'when team users are found' do
      it 'returns team user' do
        allow(TeamsUser).to receive(:find_by).with(team_id: team.id).and_return(team_user)
        expect(TeamsUser.first_by_team_id(team.id)).to eq(team_user)
      end
    end

    context 'when no team users are found' do
      it 'returns team user' do
        allow(TeamsUser).to receive(:find_by).with(team_id: 2).and_return(nil)
        expect(TeamsUser.first_by_team_id(2)).to eq(nil)
      end
    end
  end

  describe '#team_empty?' do
    context 'when team users are found' do
      it 'returns false' do
        allow(TeamsUser).to receive(:where).with('team_id = ?', team.id).and_return([team_user])
        expect(TeamsUser.team_empty?(team.id)).to be false
      end
    end

    context 'when no team users are found' do
      it 'returns true' do
        allow(TeamsUser).to receive(:where).with('team_id = ?', 2).and_return([])
        expect(TeamsUser.team_empty?(2)).to be true
      end
    end
  end

  describe '#add_member_to_invited_team' do
    context 'when invited user, team user and assignment team are all found' do
      it 'returns true' do
        allow(TeamsUser).to receive(:where).with(team_id: team.id).and_return([team_user])
        allow(TeamsUser).to receive(:where).with(['user_id = ?', team.id]).and_return([team_user])
        allow(AssignmentTeam).to receive(:find_by).with(id: team.id, parent_id: team.parent_id).and_return(team)
        allow(User).to receive(:find).with(user.id).and_return(user)
        allow(TeamsUser).to receive(:create).with(user_id: user.id, team_id: team.id).and_return(team_user)
        allow(TeamNode).to receive(:find_by).with(node_object_id: 1).and_return(double('TeamNode', id: 1))
        expect(TeamsUser.add_member_to_invited_team(team.id, user.id, team.id)).to be true
      end
    end

    context 'when team user or assignment team is not found' do
      it 'returns nil when team user is not found' do
        allow(TeamsUser).to receive(:where).with(['user_id = ?', team.id]).and_return([])
        expect(TeamsUser.add_member_to_invited_team(team.id, user.id, team.id)).to eq(nil)
      end

      it 'returns nil when assignment team is not found' do
        allow(TeamsUser).to receive(:where).with(['user_id = ?', team.id]).and_return([team_user])
        allow(AssignmentTeam).to receive(:find_by).with(id: team.id, parent_id: team.parent_id).and_return(nil)
        allow(User).to receive(:find).with(user.id).and_return(user)
        expect(TeamsUser.add_member_to_invited_team(team.id, user.id, team.id)).to eq(nil)
      end
    end
  end

  describe '#team_id' do
    context 'when teams user and team are found' do
      it 'returns team user id' do
        allow(TeamsUser).to receive(:where).with(user_id: user.id).and_return([team_user])
        allow(Team).to receive(:find).with(team.id).and_return(team)
        expect(TeamsUser.team_id(team.id, user.id)).to eq(team_user.id)
      end
    end

    context 'when teams user is not found' do
      it 'nil' do
        allow(TeamsUser).to receive(:where).with(user_id: user.id).and_return([])
        expect(TeamsUser.team_id(team.id, user.id)).to eq(nil)
      end
    end

    context 'when teams parent id varies from assignment id' do
      it 'nil' do
        allow(TeamsUser).to receive(:where).with(user_id: user.id).and_return([team_user])
        allow(Team).to receive(:find).with(team.id).and_return(Team.new)
        expect(TeamsUser.team_id(team.id, user.id)).to eq(nil)
      end
    end
  end
end
