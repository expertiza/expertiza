describe ReviewBid  do
  let(:bid1) {build(:review_bid, priority: 3, participant_id: 7601, signuptopic_id: 123, assignment_id: 2085, updated_at: '2018-01-01 00:00:00')}
  let(:bid2) {build(:review_bid, priority: 2, participant_id: '7602', signuptopic_id: 124, assignment_id: 2086)}
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student, assignment: assignment) }
  let(:topic) { build(:topic, id: 1, topic_name: "New Topic") }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:reviewer1) {double('Participant', id: 1, name: 'reviewer')}

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

  describe 'bidding_data validation' do
    it 'checks if get_bidding_data returns bidding_data as a hash' do
      test_reviewers = []
      expect(ReviewBid.get_bidding_data(bid1.assignment_id,test_reviewers)).to be_a_kind_of(Hash)
    end
  end

end