describe WaitlistTeam do
  let(:assignment) { build(:assignment, id: 1, name: 'assignment1') }
  let(:participant) { build(:participant, user_id: 1) }
  let(:user) { build(:student, id: 1, name: 'new_name', fullname: 'new name', participants: [participant]) }
  let(:team) { build(:assignment_team, id: 1, name: 'team1', users: [user]) }
  let(:team_user) { build(:team_user, id: 1, user: user) }

  before(:each) do
    allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
  end

  let(:topic1) { build(:topic, id: 1) }
  let(:topic2) { build(:topic, id: 2) }
  let(:waitlist_team1) { build(:waitlist_team) }
  let(:waitlist_team2) { build(:waitlist_team) }
  let(:waitlist_team3) { build(:waitlist_team) }
  let(:signedupteam1) { build(:signed_up_team) }

  describe 'CRUD WaitlistTeam' do
    before(:each) do
      allow(waitlist_team1).to receive(:topic_id).and_return(1)
      allow(waitlist_team1).to receive(:team_id).and_return(1)
      allow(waitlist_team2).to receive(:topic_id).and_return(2)
      allow(waitlist_team2).to receive(:team_id).and_return(2)
    end

    it 'adds and removes a team from the topic waitlist' do
      expect(WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
      expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
    end

    it 'cannot remove a team that does not exist from the topic waitlist' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
      expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team2.topic_id,1)).to be_truthy
    end
  end
end