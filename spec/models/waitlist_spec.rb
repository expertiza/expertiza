describe Waitlist do
  let(:topic1) { build(:topic, id: 1) }
  let(:topic2) { build(:topic, id: 2) }
  let(:signedupteam1) { build(:signed_up_team) }
  let(:signedupteam2) { build(:signed_up_team) }
  let(:signedupteam3) { build(:signed_up_team, is_waitlisted: false) }
  let(:signedupteam4) { build(:signed_up_team, is_waitlisted: true) }
  before(:each) do
    allow(signedupteam1).to receive(:topic_id).and_return(1)
    allow(signedupteam2).to receive(:topic_id).and_return(2)
    allow(signedupteam3).to receive(:topic_id).and_return(1)
    allow(signedupteam4).to receive(:topic_id).and_return(1)
  end
  describe '#cancel_all_waitlists' do
    it 'destroys signed up teams' do
      allow(SignUpTopic).to receive(:find_waitlisted_topics).and_return([topic1, topic2])
      allow(SignedUpTeam).to receive(:find_by).with(topic_id: 1).and_return(signedupteam1)
      allow(SignedUpTeam).to receive(:find_by).with(topic_id: 2).and_return(signedupteam2)
      allow_any_instance_of(SignedUpTeam).to receive(:destroy).and_return(true)
      expect(Waitlist.cancel_all_waitlists(0, 0)).to be_truthy
    end
  end
  describe '#remove_from_waitlists' do
    it 'reassigns other teams' do
      allow(SignedUpTeam).to receive(:where).with(team_id: 1).and_return([signedupteam1])
      allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: false).and_return([])
      allow(SignedUpTeam).to receive(:find_by).with(topic_id: 1, is_waitlisted: true).and_return(signedupteam4)
      allow(SignUpTopic).to receive(:find).and_return(topic1)
      allow_any_instance_of(SignedUpTeam).to receive(:destroy).and_return(true)
      allow(SignUpTopic).to receive(:assign_to_first_waiting_team).and_return(true)
      expect(SignUpTopic).to receive(:assign_to_first_waiting_team)
      Waitlist.remove_from_waitlists(1)
    end
  end
end
