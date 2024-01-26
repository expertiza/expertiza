describe ReviewBid do
  let(:bid1) { build(:review_bid, priority: 3, participant_id: 7601, signuptopic_id: 123, assignment_id: 2085, updated_at: '2018-01-01 00:00:00') }
  let(:bid2) { build(:review_bid, priority: 2, participant_id: '7602', signuptopic_id: 124, assignment_id: 2086) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student, assignment: assignment1) }
  let(:topic) { build(:topic, id: 1, topic_name: 'New Topic') }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:reviewer1) { double('Participant', id: 1, name: 'reviewer') }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name') }

  describe ReviewBid, type: :model do
    before(:each) do
      # Assuming you have factories set up for ReviewBid
      @review_bid = build(:review_bid)
    end
  end

  describe ReviewBid, type: :model do
    describe 'validations' do
      it 'validates presence of signuptopic_id' do
        # Assuming you have a factory for review_bids
        bid_without_topic = build(:review_bid, signuptopic_id: nil)
        expect(bid_without_topic.valid?).to be false
        expect(bid_without_topic.errors[:signuptopic_id]).to include("can't be blank")
      end
    end
  end

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
    before do
      @review_bid = ReviewBid.new
    end
  end

  describe '#assign_review_topics' do
    before do
      @review_bid = ReviewBid.new
    end

    it 'does not call assign_topic_to_reviewer if no topics are matched' do
      matched_topics = { '1' => [] } # No topics are matched for reviewer with id 1
      expect(ReviewBid).not_to receive(:assign_topic_to_reviewer) # We expect the method not to be called
      @review_bid.assign_review_topics(1, [1], matched_topics) # Call the method with no matched topics
    end

  end

  describe '#assign_topic_to_reviewer' do
    before do
      @review_bid = ReviewBid.new
    end
    context 'when there are no SignUpTeam' do
      it 'returns an empty array' do
        allow(SignedUpTeam).to receive_message_chain(:where, :pluck, :first).and_return(nil)
        expect(@review_bid.assign_topic_to_reviewer(1, 1, topic)).to eq([])
      end
    end
    context 'when there is a team to review' do
      it 'calls ReviewResponseMap' do
        allow(SignedUpTeam).to receive_message_chain(:where, :pluck, :first).and_return(team1)
        expect(ReviewResponseMap).to receive(:create)
        @review_bid.assign_topic_to_reviewer(1, 1, topic)
      end
    end
  end

  describe ReviewBid, type: :model do
    describe 'validations' do
      it 'validates presence of signuptopic_id' do
        bid_without_topic = build(:review_bid, signuptopic_id: nil)
        expect(bid_without_topic).not_to be_valid
        expect(bid_without_topic.errors[:signuptopic_id]).to include("can't be blank")
      end
    end
  end

  describe 'additional parameter tests' do
    it 'checks if participant_id is a number' do
      expect(bid1.participant_id).to be_a(Integer)
    end

    it 'checks if assignment_id is consistent' do
      expect(bid1.assignment_id).to eq(2085)
      expect(bid2.assignment_id).to eq(2086)
    end
  end

  describe 'additional bidding_data validation for non-existent users' do
    before do
      @review_bid = ReviewBid.new
    end
  end
end
