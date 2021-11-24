describe Duty do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:participant) { build(:participant, id:1, user_id: 1) }
  let(:participant2) { build(:participant, id:2, user_id: 2) }
  let(:participant3) { build(:participant, id:3, user_id: 3) }
  let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
  let(:user2) { build(:student, id: 2, name: 'no name2', fullname: 'no one2', participants: [participant2]) }
  let(:user3) { build(:student, id: 3, name: 'no name3', fullname: 'no one3', participants: [participant3]) }

  let(:team1) { build(:assignment_team, id: 1, name: 'no team', users: [user, user2, user3]) }
  let(:sample_duty_taken) { build(:duty, id: 1, max_members_for_role:1, assignment_id:1) }
  let(:sample_duty_not_taken) { build(:duty, id: 1, max_members_for_role:2, assignment_id:1) }

  let(:team_user1) { build(:team_user, id: 1, user: user) }
  let(:team_user2) { build(:team_user, id: 2, user: user2) }
  let(:team_user3) { build(:team_user, id: 3, user: user3, duty_id:1) }

  before(:each) do
    allow(team1).to receive(:participants).and_return([participant, participant2, participant3])
    allow(participant).to receive(:get_team_user).and_return(team_user1)
    allow(participant2).to receive(:get_team_user).and_return(team_user2)
    allow(participant3).to receive(:get_team_user).and_return(team_user3)
  end

  describe '#can_be_assigned?' do
    context 'when users in current team want to assign roles that are available'
      it 'returns true' do
        expect(sample_duty_not_taken.can_be_assigned?(team1)).to be true
      end
    context 'when users in current team want to assign roles that are unavailable'
    it 'returns false' do
      expect(sample_duty_taken.can_be_assigned?(team1)).to be false
    end

  end

end
