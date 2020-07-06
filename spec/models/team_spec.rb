describe Team do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:participant) { build(:participant, user_id: 1) }
  let(:participant2) { build(:participant, user_id: 2) }
  let(:participant3) { build(:participant, user_id: 3) }
  let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
  let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user]) }
  let(:team2) { build(:assignment_team, id: 2, name: 'assignment team', users: []) }
  let(:team3) { build(:course_team, id: 3, name: 'course team', users: [user2]) }
  let(:team_user) { build(:team_user, id: 1, user: user) }
  before(:each) do
    allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
  end
  describe '#participant' do
    it 'gets the participants of current team, by default returns an empty array' do
      expect(team.participants).to eq([])
    end
  end

  describe '#responses' do
    it 'gets the response done by participants in current team, by default returns an empty array' do
      expect(team.responses).to eq([])
    end
  end

  describe '#delete' do
    it 'deletes the current team and related objects and return self' do
      allow(TeamsUser).to receive_message_chain(:where, :find_each).with(team_id: 1).with(no_args).and_yield(team_user)
      allow(team_user).to receive(:destroy).and_return(team_user)
      node = double('TeamNode')
      allow(TeamNode).to receive(:find_by).with(node_object_id: 1).and_return(node)
      allow(node).to receive(:destroy).and_return(node)
      expect(team.delete).to eq(team)
    end
  end

  describe '#node_type' do
    it 'always returns TeamNode' do
      expect(team.node_type).to eq('TeamNode')
    end
  end

  describe '#author_names' do
    it 'returns an array of author\'s name' do
      expect(team.author_names).to eq(['no one'])
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
        expect(team.user?(double('User'))).to be false
      end
    end
  end

  describe '#full?' do
    context 'when the parent_id of current team is nil' do
      it 'returns false' do
        team.parent_id = nil
        expect(team.full?).to be false
      end
    end

    context 'when the parent_id of current team is not nil' do
      before(:each) do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
      end
      context 'when the current team size is bigger than or equal to max team members' do
        it 'returns true' do
          allow(Team).to receive(:size).and_return(6)
          expect(team.full?).to be true
        end
      end

      context 'when the current team size is smaller than max team members' do
        it 'returns false' do
          allow(Team).to receive(:size).and_return(1)
          expect(team.full?).to be false
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

    context 'when parameterized user did not join in current team yet' do
      context 'when current team is not full' do
        it 'does not raise an error' do
          allow_any_instance_of(Team).to receive(:user?).with(user).and_return(false)
          allow_any_instance_of(Team).to receive(:full?).and_return(false)
          allow(TeamsUser).to receive(:create).with(user_id: 1, team_id: 1).and_return(team_user)
          allow(TeamNode).to receive(:find_by).with(node_object_id: 1).and_return(double('TeamNode', id: 1))
          allow_any_instance_of(Team).to receive(:add_participant).with(1, user).and_return(double('Participant'))
          expect(team.add_member(user)).to be true
        end
      end
    end
  end

  describe '.size' do
    it 'returns the size of current team' do
      expect(Team.size(1)).to eq(1)
    end
  end

  describe '#copy_members' do
    it 'copies members from current team to a new team' do
      allow(TeamsUser).to receive(:create).with(team_id: 2, user_id: 1).and_return(team_user)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      expect(team.copy_members(double('Team', id: 2))).to eq([team_user])
    end
  end

  describe '.check_for_existing' do
    context 'when team exists' do
      it 'raises a TeamExistsError' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1, name: 'no name').and_return([team])
        expect { Team.check_for_existing(assignment, 'no name', 'Assignment') }
          .to raise_error(TeamExistsError, "The team name no name is already in use.")
      end
    end

    context 'when team exists' do
      it 'returns nil' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1, name: 'no name').and_return([])
        expect(Team.check_for_existing(assignment, 'no name', 'Assignment')).to be nil
      end
    end
  end

  describe '.randomize_all_by_parent' do
    it 'forms teams and assigns team members automatically' do
      allow(Participant).to receive(:where).with(parent_id: 1, type: 'AssignmentParticipant')
                                           .and_return([participant, participant2, participant3])
      allow(User).to receive(:find).with(1).and_return(user)
      allow(User).to receive(:find).with(2).and_return(user2)
      allow(User).to receive(:find).with(3).and_return(user3)
      allow(Team).to receive(:where).with(parent_id: 1, type: 'AssignmentTeam').and_return([team])
      allow(Team).to receive(:size).with(any_args).and_return(1)
      allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
      expect(Team.randomize_all_by_parent(assignment, 'Assignment', 2)).to eq([1])
    end
  end

  describe '.generate_team_name' do
    it 'generates the unused team name' do
      allow(Team).to receive(:find_by).with(name: 'Team_1').and_return(team)

      allow(Team).to receive(:find_by).with(name: 'Team_2').and_return(nil)
      expect(Team.generate_team_name).to eq('Team_2')
    end
  end

  describe '.import_team_members' do
    context 'when cannot find a user by name' do
      it 'raises an ImportError' do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(nil)
        expect { team.import_team_members({teammembers: ['no name']}) }.to raise_error(ImportError,
                                                                                       "The user 'no name' was not found. <a href='/users/new'>Create</a> this user?")
      end
    end

    context 'when can find certain user' do
      it 'adds the user to current team' do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(user)
        allow(TeamsUser).to receive(:find_by).with(team_id: 1, user_id: 1).and_return(nil)
        allow_any_instance_of(Team).to receive(:add_member).with(user).and_return(true)
        expect(team.import_team_members({teammembers: ['no name']})).to eq(['no name'])
      end
    end
  end

  describe '.import' do
    context 'when row is empty and no options are specified' do
      it 'raises an ArgumentError' do
        expect { Team.import({}, 1, {}, AssignmentTeam.new) }
          .to raise_error(ArgumentError, 'Not enough fields on this line.')
        end
    end

    context 'when row contains only one team member and has_teamname option is true_first or true_last' do
      it 'raises an ArgumentError' do
        expect { Team.import({teammembers: [user.name]}, 1, {has_teamname: 'true_first'}, AssignmentTeam.new) }
          .to raise_error(ArgumentError, 'Not enough fields on this line.')
      end

      it 'raises an ArgumentError' do
        expect { Team.import({teammembers: [user.name]}, 1, {has_teamname: 'true_last'}, AssignmentTeam.new) }
          .to raise_error(ArgumentError, 'Not enough fields on this line.')
      end
    end

    context 'when row contains only one team member, no options, and team type is AssignmentTeam' do
      it 'generates new name, saves new team with new name in DB and imports team members' do
        allow(Team).to receive(:find_by).with(name: 'Team_1').and_return(nil)
        allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(team)
        allow(team).to receive(:import_team_members).with(teammembers: [user.name]).and_return(true)
        expect(team).to receive(:import_team_members).with(teammembers: [user.name])
        expect(Team.import({teammembers: [user.name]}, 1, {}, AssignmentTeam.new)).to be true
      end
    end

    context 'when row contains only one team member, no options, and team type is Team' do
      it 'name is not generated, returns without creating new team and importing team members' do
        expect(Team).to_not receive(:create_team_and_node).with(1)
        expect(team).to_not receive(:import_team_members).with(teammembers: [user.name])
        Team.import({teammembers: [user.name]}, 1, {}, Team.new)
      end
    end

    context 'when row contains team name and multiple team members and multiple options are given' do
      it 'handles duplicated teams by renaming it and imports team members into renamed team' do
        allow(Team).to receive(:find_by).with(name: team.name, parent_id: 1).and_return(team)
        allow(Team).to receive(:find_by).with(name: 'Team_1').and_return(nil)
        allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(team)
        allow(team).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name]).and_return(true)
        expect(team).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name])
        # Generate with options has_teamname: 'true_first', handle_dups: 'rename'
        expect(Team.import({teamname: team.name, teammembers: [user.name, user2.name]}, 1,
                           {has_teamname: 'true_first', handle_dups: 'rename'}, AssignmentTeam.new)).to be true
      end

      it 'handles duplicated teams by replacing old team and imports team members into new team' do
        allow(Team).to receive(:find_by).with(name: team.name, parent_id: 1).and_return(team)
        allow(TeamsUser).to receive_message_chain(:where, :find_each).with(team_id: 1).with(no_args).and_yield(team_user)
        allow(team_user).to receive(:destroy).and_return(team_user)
        allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(team2)
        allow(team2).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name]).and_return(true)
        expect(team2).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name])
        # Generate with options has_teamname: 'true_last', handle_dups: 'replace'
        expect(Team.import({teamname: team.name, teammembers: [user.name, user2.name]}, 1,
                           {has_teamname: 'true_last', handle_dups: 'replace'}, AssignmentTeam.new)).to be true
      end

      it 'does not create new team, but imports team members into existing team' do
        allow(Team).to receive(:find_by).with(name: team.name, parent_id: 1).and_return(team)
        allow(User).to receive(:find_by).with(name: user.name).and_return(user)
        allow(User).to receive(:find_by).with(name: user2.name).and_return(user2)
        allow(TeamsUser).to receive(:find_by).with(team_id: 1, user_id: 1).and_return(team_user)
        allow(TeamsUser).to receive(:find_by).with(team_id: 1, user_id: 2).and_return(team_user)
        expect(AssignmentTeam).to_not receive(:create_team_and_node).with(1)
        allow(team).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name]).and_return(true)
        expect(team).to receive(:import_team_members).with(teamname: team.name, teammembers: [user.name, user2.name])
        # Generate with options has_teamname: 'true_first'
        expect(Team.import({teamname: team.name, teammembers: [user.name, user2.name]}, 1,
                           {has_teamname: 'true_first'}, AssignmentTeam.new)).to be true
      end

      it 'has no duplicate, creates new team and imports team members ' do
        allow(Team).to receive(:find_by).with(name: '', parent_id: 1).and_return(nil)
        allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(team)
        allow(team).to receive(:import_team_members).with(teammembers: [user.name, user2.name]).and_return(true)
        expect(team).to receive(:import_team_members).with(teammembers: [user.name, user2.name])
        # Generate with options has_teamname: 'true_last'
        expect(Team.import({teammembers: [user.name, user2.name]}, 1,
                           {has_teamname: 'true_last'}, AssignmentTeam.new)).to be true
      end

      it 'ignores duplicates, does not creates new team, and does not imports team members ' do
        allow(Team).to receive(:find_by).with(name: team.name, parent_id: 1).and_return(team)
        expect(AssignmentTeam).to_not receive(:create_team_and_node).with(1)
        expect(team).to_not receive(:import_team_members).with(teammembers: [user.name, user2.name])
        # Generate with options has_teamname: 'true_last', handle_dups: 'replace'
        Team.import({teamname: team.name, teammembers: [user.name, user2.name]}, 1,
                    {has_teamname: 'true_last', handle_dups: 'ignore'}, AssignmentTeam.new)
      end
    end

    # E1776 (Fall 2017)
    #
    # The tests below are no longer reflective of the current import that uses row_hash ==> {teammembers: ['name', 'name'], teamname: 'teamname'}.
    #
    # context 'when has_column_names option is true' do
    #   it 'handles duplicated teams and imports team members' do
    #     allow(Team).to receive(:find_by).with(name: 'no team', parent_id: 1).and_return(team)
    #     allow_any_instance_of(Team).to receive(:handle_duplicate)
    #       .with(team, 'no team', 1, 'rename', AssignmentTeam.new).and_return('new team name')
    #     allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(AssignmentTeam.new)
    #     allow_any_instance_of(Team).to receive(:import_team_members).with(1, ['no team', 'another field']).and_return(true)
    #     expect(Team.import(['no team', 'another field'], 1, {has_column_names: 'true'}, AssignmentTeam.new)).to be true
    #   end
    # end
    #
    # context 'when has_column_names option is not true' do
    #   it 'generated team name directly and imports team members' do
    #     allow(Assignment).to receive(:find).with(1).and_return(assignment)
    #     allow(Team).to receive(:generate_team_name).with('no assgt').and_return('new team name')
    #     allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(AssignmentTeam.new)
    #     allow_any_instance_of(Team).to receive(:import_team_members).with(0, ['no team', 'another field']).and_return(true)
    #     expect(Team.import(['no team', 'another field'], 1, {has_column_names: 'false'}, AssignmentTeam.new)).to be true
    #   end
    # end
  end

  describe '.handle_duplicate' do
    context 'when parameterized team is nil' do
      it 'returns team name' do
        expect(Team.handle_duplicate(nil, 'no name', 'replace', CourseTeam.new)).to eq('no name')
      end
    end

    context 'when parameterized team is not nil' do
      context 'when handle_dups option is ignore' do
        it 'does not create the new team and returns nil' do
          expect(Team.handle_duplicate(team, 'no name', 'ignore', CourseTeam.new)).to be nil
        end
      end

      context 'when handle_dups option is rename' do
        it 'returns new team name' do
          allow(Course).to receive(:find).with(1).and_return(double('Course', name: 'no course'))
          allow(Team).to receive(:generate_team_name).and_return('new team name')
          expect(Team.handle_duplicate(team, 'no name', 'rename', CourseTeam.new)).to eq('new team name')
        end
      end

      context 'when handle_dups option is replace' do
        it 'deletes the old team' do
          allow(TeamsUser).to receive_message_chain(:where, :find_each).with(team_id: 1).with(no_args).and_yield(team_user)
          allow(team_user).to receive(:destroy).and_return(team_user)
          expect(Team.handle_duplicate(team, 'no name', 'replace', CourseTeam.new)).to eq('no name')
        end
      end
    end
  end

  describe '.export' do
    context 'when exporting single assignment and course teams to csv' do
      it 'exports single assignments team to csv' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team])
        allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
        expect(Team.export([], 1, {team_name: 'false'}, AssignmentTeam.new)).to eq([[team.name, user.name]])
      end
      it 'exports single course team to csv' do
        allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([team3])
        allow(TeamsUser).to receive(:where).with(team_id: 3).and_return([team_user])
        expect(Team.export([], 1, {team_name: 'false'}, CourseTeam.new)).to eq([[team3.name, user.name]])
      end
      it 'exports only single assignment team name to csv' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team])
        allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
        expect(Team.export([], 1, {}, AssignmentTeam.new)).to eq([[team.name]])
      end
    end

    context 'when exporting multiple assignment teams to csv' do
      it 'exports single assignments team to csv' do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team, team2])
        allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
        allow(TeamsUser).to receive(:where).with(team_id: 2).and_return([])
        expect(Team.export([], 1, {team_name: 'false'}, AssignmentTeam.new)).to eq([[team.name, user.name], [team2.name]])
      end
    end

    context 'when exporting unhandled teams to csv' do
      it 'does not export unhandled teams to csv' do
        expect(Team.export([], 1, {team_name: 'false'}, Team.new)).to be_empty
      end
    end
  end
end
