describe ReviewBid do
  let(:bid1) { build(:review_bid, priority: 3, participant_id: 7601, signuptopic_id: 123, assignment_id: 2085, updated_at: '2018-01-01 00:00:00') }
  let(:bid2) { build(:review_bid, priority: 2, participant_id: '7602', signuptopic_id: 124, assignment_id: 2086) }
  let(:student) { build(:student, id: 1, username: 'name', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student, assignment: assignment1) }
  let(:topic) { build(:topic, id: 1, topic_name: 'New Topic') }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:reviewer1) { double('Participant', id: 1, name: 'reviewer') }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name') }

  describe 'test review bid parameters'  do
    it 'returns the signuptopic_id of the bid' do
      expect(bid1.signuptopic_id).to eq(123)
    end

    it 'returns priority of the bid' do
      expect(bid1.priority).to eq(3)
    end

    it 'validates that priority should not be a string' do
      expect(bid2.priority).not_to eq('2')
    end

    it 'validates that updated_at field should accept a string' do
      expect(bid1.updated_at).to eq('2018-01-01 00:00:00')
    end
  end

  describe '#bidding_data validation' do
    it 'checks if get_bidding_data returns bidding_data as a hash' do
      test_reviewers = [1]
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      allow(SignedUpTeam).to receive(:topic_id).and_return(1)
      allow(ReviewBid).to receive(:where).and_return([bid1, bid2])
      expect(ReviewBid.bidding_data(bid1.assignment_id, test_reviewers)).to eq('max_accepted_proposals' => nil, 'tid' => [], 'users' => { 1 => { 'otid' => 1, 'priority' => [3, 2], 'tid' => [123, 124], 'time' => ['2018-01-01 00:00:00.000000000 +0000', nil] } })
    end
  end

  describe '#assign_review_topics' do
    it 'calls assigns_topics_to_reviewer for as many topics associated' do
      maps = [response_map]
      matched_topics = { '1' => [topic] }
      allow(ReviewResponseMap).to receive(:where).and_return(maps)
      allow(maps).to receive(:destroy_all).and_return(true)
      expect(ReviewBid).to receive(:assign_topic_to_reviewer).with(1, 1, topic)
      ReviewBid.assign_review_topics(1, [1], matched_topics)
    end
  end

  describe '#assign_topic_to_reviewer' do
    context 'when there are no SignUpTeam' do
      it 'returns an empty array' do
        allow(SignedUpTeam).to receive_message_chain(:where, :pluck, :first).and_return(nil)
        expect(ReviewBid.assign_topic_to_reviewer(1, 1, topic)).to eq([])
      end
    end
    context 'when there is a team to review' do
      it 'calls ReviewResponseMap' do
        allow(SignedUpTeam).to receive_message_chain(:where, :pluck, :first).and_return(team1)
        expect(ReviewResponseMap).to receive(:create)
        ReviewBid.assign_topic_to_reviewer(1, 1, topic)
      end
    end
  end
end
