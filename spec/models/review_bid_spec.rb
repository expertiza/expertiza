RSpec.describe ReviewBid, type: :model do
  let(:assignment) { create(:assignment) }
  let(:reviewers) { create_list(:participant, 3) }
  let(:topics) { create_list(:signup_topic, 3, assignment: assignment) }
  let(:signed_up_teams) do
    topics.map { |topic| create(:signed_up_team, topic: topic, team: create(:team)) }
  end
  let(:bid1) { build(:review_bid, priority: 3, participant_id: 7601, signuptopic_id: 123, assignment_id: 2085, updated_at: '2018-01-01 00:00:00') }
  let(:bid2) { build(:review_bid, priority: 2, participant_id: '7602', signuptopic_id: 124, assignment_id: 2086) }
  let(:matched_topics) { { reviewers[0].id => 1, reviewers[1].id => 2, reviewers[2].id => 3 } }

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

    it 'ensures signed_up_teams have valid team_ids' do
      signed_up_teams.each do |sut|
        expect(sut.team_id).not_to be_nil
      end
    end
    
    it 'checks the relation between topics and signed_up_teams' do
      expect(signed_up_teams.map(&:topic_id)).to include(*topics.map(&:id))
    end
  end
  
  describe 'bidding_data' do
    context 'when assignment_id and reviewer_ids are valid' do
      it 'returns correct topic IDs' do
        topic_ids = topics.map(&:id)
        signed_up_teams.map { |sut| { team_id: sut.team_id, topic_id: sut.topic_id } }
        result = ReviewBid.bidding_data(assignment.id, reviewers.map(&:id))
        expect(result['tid']).to match_array(topic_ids)
      end

      it 'returns correct max_accepted_proposals' do
        max_reviews = assignment.num_reviews_allowed
        result = ReviewBid.bidding_data(assignment.id, reviewers.map(&:id))
        expect(result['max_accepted_proposals']).to eq(max_reviews)
      end

      
      it 'returns the bidding data for the given assignment and reviewers' do
        expect(ReviewBid.bidding_data(assignment.id, reviewers.map(&:id))).to be_a(Hash)
      end

      it 'handles a single reviewer' do
        expect(ReviewBid.bidding_data(assignment.id, [reviewers.first.id])).to be_a(Hash)
      end 

      it 'When there are no reviewer_ids and assignment_id has valid data' do
        result = ReviewBid.bidding_data(assignment.id, [])
        expect(result).to be_a(Hash)
        expect(result['tid']).to be_empty
        expect(result['users']).to be_empty
      end

      it 'When there are multiple reviewer_ids and assignment_id is nil' do
        result=ReviewBid.bidding_data(nil, [1, 2, 3])
        expect(result).to be_a(Hash)
        expect(result['tid']).to be_empty
        expect(result['users']).to be_empty
        expect(result['max_accepted_proposals']).to be_nil
      end
 
      it 'When assignment_id is valid but reviewer_ids is nil' do
        result = ReviewBid.bidding_data(assignment.id, nil)
        expect(result).to be_a(Hash)
        expect(result['tid']).to be_empty
        expect(result['users']).to be_empty
        expect(result['max_accepted_proposals']).to be_nil
      end
    end

    context 'when assignment_id or reviewer_ids are invalid' do
      it 'returns an empty hash when both assignment_id and reviewer_ids are nil' do
        result = ReviewBid.bidding_data(nil, nil)
        expect(result).to eq({'tid' => [], 'users' => {}, 'max_accepted_proposals' => nil})
      end

      it 'returns an empty hash when assignment_id is nil but reviewer_ids has valid data' do
        result = ReviewBid.bidding_data(nil, [7, 8])
        expect(result).to eq({'tid' => [], 'users' => {}, 'max_accepted_proposals' => nil})
      end

      it 'returns an empty hash when assignment_id has valid data but reviewer_ids is an empty array' do
        result = ReviewBid.bidding_data(5, [])
        expect(result).to eq({'tid' => [], 'users' => {}, 'max_accepted_proposals' => nil})
      end
    end
  end

  describe ".assign_topic_to_reviewer" do
    
    context "When there is a signed up team for the given topic" do
      it "create a ReviewResponseMap with the correct assignment_id, reviewer_id, and reviewee_id" do
        signed_up_teams.each_with_index do |signed_up_team, index|
          ReviewBid.assign_topic_to_reviewer(assignment.id, reviewers[index].id, signed_up_team.topic_id)
          expect(ReviewResponseMap.last).to have_attributes(
            reviewed_object_id: assignment.id,
            reviewer_id: reviewers[index].id,
            reviewee_id: signed_up_team.team_id
          )
        end
      end
    end
    context "When there are no signed up teams for the given topic" do 
      it "does not create any new review response maps" do
        expect {
          ReviewBid.assign_topic_to_reviewer(assignment.id, reviewers.first.id, 'topic3')
        }.not_to change { ReviewResponseMap.count }
      end
    end
  end

  describe "#reviewer_bidding_data" do
    
    context "when reviewer_id is invalid" do
      it "raises an error" do
        expect {
          ReviewBid.reviewer_bidding_data(-1, assignment.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end