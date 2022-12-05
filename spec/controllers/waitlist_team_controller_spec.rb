describe WaitlistTeamController do
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

  describe 'CRUD WaitlistTeamController' do
    before(:each) do
      allow(waitlist_team1).to receive(:topic_id).and_return(1)
      allow(waitlist_team1).to receive(:team_id).and_return(1)
      allow(waitlist_team2).to receive(:topic_id).and_return(2)
      allow(waitlist_team2).to receive(:team_id).and_return(2)
    end

    it 'adds first waitlist team in the topic waitlist' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      signed_up_team = WaitlistTeamController.signup_first_waitlist_team(1)
      expect(signed_up_team).to be_instance_of(SignedUpTeam) or  expect(signed_up_team).to be_nil
      expect(WaitlistTeamController.team_has_any_waitlists?(waitlist_team1.team_id)).to be_truthy
    end
    
    it 'check if team does not has any waitlists' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeamController.team_has_any_waitlists?(waitlist_team1.team_id)).to be_falsey
    end
    
    it 'check if topic does not has any waitlists' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeamController.topic_has_any_waitlists?(waitlist_team1.topic_id)).to be_falsey
    end
    
    it 'check and delete all waitlists for a team' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeamController.delete_all_waitlists_for_team(waitlist_team1.team_id)).to be_truthy
    end
    
    it 'check and delete all waitlists for a topic' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeamController.delete_all_waitlists_for_topic(waitlist_team1.topic_id)).to be_truthy
    end
    
    it 'verify team waitlisted for topic' do
      WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
      expect(WaitlistTeamController.check_team_waitlisted_for_topic(waitlist_team1.team_id, waitlist_team1.topic_id)).to be_truthy
    end
  end
end