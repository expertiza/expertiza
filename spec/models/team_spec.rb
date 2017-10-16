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
  describe '#participant' do
    it 'gets the participants of current team, by default returns an empty array'
  end

  describe '#responses' do
    it 'gets the response done by participants in current team, by default returns an empty array'
  end

  describe '#delete' do
    it 'deletes the current team and related objects and return self'
  end

  describe '#get_node_type' do
    it 'always returns TeamNode'
  end

  describe '#get_author_names' do
    it 'returns an array of author\'s name'
  end

  describe '#has_user' do
    context 'when users in current team includes the parameterized user' do
      it 'returns true'
    end

    context 'when users in current team does not include the parameterized user' do
      it 'returns false'
    end
  end

  describe '#full?' do
    context 'when the parent_id of current team is nil' do
      it 'returns false'
    end

    context 'when the parent_id of current team is not nil' do
      context 'when the current team size is bigger than or equal to max team members' do
        it 'returns true'
      end

      context 'when the current team size is smaller than max team members' do
        it 'returns false'
      end
    end
  end

  describe '#add_member' do
    context 'when parameterized user has already joined in current team' do
      it 'raise an error'
    end

    context 'when parameterized user did join in current team yet' do
      context 'when current team is not full' do
        it 'raise an error'
      end
    end
  end

  describe '.size' do
    it 'returns the size of current team'
  end

  describe '#copy_members' do
    it 'copies members from current team to a new team'
  end

  describe '.check_for_existing' do
    context 'when team exists' do
      it 'raises a TeamExistsError'
    end

    context 'when team exists' do
      it 'returns nil'
    end
  end

  describe '.randomize_all_by_parent' do
    it 'forms teams and assigns team members automatically'
  end

  describe '.generate_team_name' do
    it 'generates the unused team name'
  end

  describe '.import_team_members' do
    context 'when cannot find a user by name' do
      it 'raises an ImportError'
    end

    context 'when can find certain user' do
      it 'adds the user to current team'
    end
  end

  describe '.import' do
    context 'when row is empty and has_column_names option is not true' do
      it 'raises an ArgumentError'
    end

    context 'when has_column_names option is true' do
      it 'handles duplicated teams and imports team members'
    end

    context 'when has_column_names option is not true' do
      it 'generated team name directly and imports team members'
    end
  end

  describe '.handle_duplicate' do
    context 'when parameterized team is nil' do
      it 'returns team name'
    end

    context 'when parameterized team is not nil' do
      context 'when handle_dups option is ignore' do
        it 'does not create the new team and returns nil'
      end

      context 'when handle_dups option is rename' do
        it 'returns new team name'
      end

      context 'when handle_dups option is replace' do
        it 'deletes the old team'
      end
    end
  end

  describe '.export' do
    it 'exports teams to csv'
  end
end
