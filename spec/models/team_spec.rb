describe Team do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:participant) { build(:participant, user_id: 1) }
  let(:participant2) { build(:participant, user_id: 2) }
  let(:participant3) { build(:participant, user_id: 3) }
  let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
  let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user]) }
  let(:team_user) { build(:team_user, id: 1, user: user) }

  before(:each) do
    allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
  end
  describe '#participants' do
    it 'gets the participants of current team, by default returns an empty array' do
      expect(team.participants).to eq []
    end
  end

  describe '#responses' do
    it 'gets the response done by participants in current team, by default returns an empty array' do
      expect(team.responses).to eq []
    end
  end

  describe '#delete' do
    it 'deletes the current team and related objects and return self' do
      expect(team.delete).to eql team
    end
  end

  describe '#node_type' do
    it 'always returns TeamNode' do
      expect(team.node_type).to eq 'TeamNode'
    end
  end

  describe '#author_names' do
    it 'returns an array of author\'s name' do
      expect(team.author_names).to eq ['no one']
    end
  end

  describe '#user?' do
    context 'when users in current team includes the parameterized user' do
      it 'returns true' do
        expect(team.user?(user)).to be true
      end
    end

    context 'when users in current team does not include the parameterized user' do
      it 'returns false' do
        expect(team.user?(user2)).to be false
      end
    end
  end

  describe '#full?' do
    context 'when the parent_id of current team is nil' do
      it 'returns false' do
        allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([])
        expect(team.full?).to eq false
      end
    end

    context 'when the parent_id of current team is not nil' do
      context 'when the current team size is bigger than or equal to max team members' do
        it 'returns true' do
          allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user, team_user, team_user])
          expect(team.full?).to eq true
        end
      end

      context 'when the current team size is smaller than max team members' do
        it 'returns false' do
          expect(team.full?).to eq false
        end
      end
    end
  end

  describe '#add_member' do
    context 'when parameterized user has already joined in current team' do
      it 'raise an error' do
        expect { team.add_member(user) }.to raise_error(RuntimeError, "The user #{user.name} is already a member of the team #{team.name}")
      end
    end

    context 'when parameterized user did join in current team yet' do
      context 'when current team is not full' do
        it 'does not raise an error' do
          expect { team.add_member(user2) }.not_to raise_error(RuntimeError, "The user #{user2.name} is already a member of the team #{team.name}")
        end
      end
    end
  end

  describe '.size' do
    it 'returns the size of current team' do
      team_user.team_id = team.id
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
      expect(Team.size(team.id)).to eq 1
    end
  end

  describe '#copy_members' do
    let(:team2) { build(:assignment_team, id: 2, name: 'no team', users: [user2]) }
    let(:team_user2) { build(:team_user, id: 2, user: user2) }
    it 'copies members from current team to a new team' do
      allow(TeamsUser).to receive(:where).with(team_id: 2).and_return([team_user2])
      allow(TeamsUser).to receive(:create).with(team_id: 2, user_id: 1).and_return(team_user)
      expect(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: team_user.id)
      team.copy_members(team2)
    end
  end

  describe '.check_for_existing' do
    context 'when team exists' do
      it 'raises a TeamExistsError' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1, name: team.name).and_return([team])
        expect { Team.check_for_existing(team, team.name, 'Assignment')}.to raise_error(TeamExistsError)
      end
    end

    context 'when team does not exist' do
      it 'returns nil' do
        expect(Team.check_for_existing(team, 'test team', 'Assignment')).to be_nil
      end
    end
  end

  describe '.randomize_all_by_parent' do
    it 'forms teams and assigns team members automatically' do
      allow(Participant).to receive(:where).with(parent_id: 1, type: "AssignmentTeamParticipant").and_return([participant])
      allow(Team).to receive(:where).with(parent_id: 1, type: "AssignmentTeamTeam").and_return([team])
      allow(User).to receive(:find).with(1).and_return(user)
      expect(Team).to receive(:sort_teams_by_members_reverse).with([team])
      Team.randomize_all_by_parent(team, 'Assignment', 2)
    end
  end

  describe '.generate_team_name' do
    it 'generates the unused team name' do
      expect(Team.generate_team_name('Test')).to eq 'Test_Team1'
    end
  end

  describe '.import_team_members' do
    context 'when cannot find a user by name' do
      it 'raises an ImportError' do
        error_message = "The user TestUser was not found. <a href='/users/new'>Create</a> this user?"
        expect { team.import_team_members(0, ['TestUser']) }.to raise_error(ImportError, error_message)
      end
    end

    context 'when can find certain user' do
      it 'adds the user to current team' do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(user)
        allow(TeamsUser).to receive(:find_by).with(team_id: 1, user_id: 1).and_return(nil)
        expect { team.import_team_members(0, ['no name']) }.to raise_error(RuntimeError, "The user #{user.name} is already a member of the team #{team.name}")
      end
    end
  end

  describe '.import' do
    context 'when row is empty and has_column_names option is not true' do
      it 'raises an ArgumentError' do
        expect { Team.import([], 1, {has_column_names: true}, AssignmentTeam) }.to raise_error(ArgumentError, 'Not enough fields on this line.')
      end
    end

    context 'when has_column_names option is true' do
      it 'handles duplicated teams and imports team members' do
        allow(Team).to receive(:find_by).with(name: team.name, parent_id: 1).and_return(team)
        allow(User).to receive(:find_by).with(name: 'no name').and_return(user2)
        allow(TeamsUser).to receive(:find_by).with(team_id: 1, user_id: 2).and_return(user2)
        expect(team).to receive(:import_team_members).with(1, ["no team", "no name"])
        Team.import(["no team", "no name"], 1, {has_column_names: "true"}, team)
      end
    end

    context 'when has_column_names option is not true' do
      it 'generated team name directly and imports team members' do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(user2)
        allow(TeamsUser).to receive(:find_by).with(team_id: 2, user_id: 2).and_return(user2)
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(Team).to receive(:generate_team_name).with("no assgt").and_return("no assgt_Team1")
        expect(Team).to receive(:generate_team_name).with("no assgt")
        Team.import(["no name"], 1, {has_column_names: "false"}, team)
      end
    end
  end

  describe '.handle_duplicate' do
    context 'when parameterized team is nil' do
      it 'returns team name' do
        expect(Team.handle_duplicate(nil, "Test Name", 1, "ignore", team)).to eql "Test Name"
      end
    end

    context 'when parameterized team is not nil' do
      context 'when handle_dups option is ignore' do
        it 'does not create the new team and returns nil' do
          expect(Team.handle_duplicate(team, "no team", 1, "ignore", team)).to be_nil
        end
      end

      context 'when handle_dups option is rename' do
        it 'returns new team name' do
          allow(Assignment).to receive(:find).with(1).and_return(assignment)
          allow(Team).to receive(:generate_team_name).with("no assgt").and_return("no assgt_Team1")
          expect(Team.handle_duplicate(team, "no team", 1, "rename", team)).to eql "no assgt_Team1"
        end
      end

      context 'when handle_dups option is replace' do
        it 'deletes the old team' do
          expect(Team.handle_duplicate(team, "no team", 1, "replace", team)).to eql "no team"
        end
      end
    end
  end

  describe '.export' do
    it 'exports teams to csv' do
      allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team])
      expect(Team.export([], 1, {team_name: "true"}, team)).to eql [["no team"]]
    end
  end
end
