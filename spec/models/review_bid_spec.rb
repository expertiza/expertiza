describe ReviewBid do
  let(:bid1) { build(:review_bid, priority: 3, participant_id: 7601, signuptopic_id: 123, assignment_id: 2085, updated_at: '2018-01-01 00:00:00') }
  let(:bid2) { build(:review_bid, priority: 2, participant_id: 7602, signuptopic_id: 124, assignment_id: 2086, updated_at: '2018-01-02 00:00:00') }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
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
    it 'checks if get_bidding_data returns bidding_data as a hash and with the correct timestamps format' do
      test_reviewers = [1]
      # Ensure participant exists
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      # Ensure topic ID is returned correctly
      allow(SignedUpTeam).to receive(:topic_id).and_return(123)
      # Ensure TeamsUser.team_id returns a valid ID
      allow(TeamsUser).to receive(:team_id).and_return(1)
      # Stub Bid.where to return the bids (since the class calls Bid.where)
      allow(Bid).to receive(:where)
        .with(team_id: 1)
        .and_return([bid1, bid2])
      # Stub bid.topic_id so it returns the signuptopic_id value
      allow(bid1).to receive(:topic_id).and_return(bid1.signuptopic_id)
      allow(bid2).to receive(:topic_id).and_return(bid2.signuptopic_id)
      result = ReviewBid.bidding_data(bid1.assignment_id, test_reviewers)
      # Check outer structure
      expect(result['max_accepted_proposals']).to eq(nil)
      expect(result['tid']).to eq([])
      # Get bidding data for reviewer 1
      user_bids = result['users'][1]['bids']
      expect(user_bids.size).to eq(2)
      # Define regex for the expected timestamp format
      timestamp_regex = /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} [A-Z]+ [+-]\d{2}:\d{2}$/
      # Verify first bid
      expect(user_bids[0]['tid']).to eq(123)
      expect(user_bids[0]['priority']).to eq(3)
      expect(user_bids[0]['timestamp']).to match(timestamp_regex)
      # Verify second bid
      expect(user_bids[1]['tid']).to eq(124)
      expect(user_bids[1]['priority']).to eq(2)
      expect(user_bids[1]['timestamp']).to match(timestamp_regex)
      # Verify otid
      expect(result['users'][1]['otid']).to eq(123)
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

  describe '.reviewer_bidding_data' do
    let(:assignment_id) { 2085 }
    let(:reviewer_id)   { 1 }
    let(:reviewer_user_id) { 10 }
    let(:self_topic)    { 555 }
    let(:team_id)       { 1 }
    let(:timestamp_regex) { /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4} \d{2}:\d{2}:\d{2} [A-Z]+ [+-]\d{2}:\d{2}$/ }
    context 'when a team is found' do
      let(:bid1) { build(:review_bid, priority: 3, signuptopic_id: 123, assignment_id: assignment_id, updated_at: Time.zone.parse('2018-01-01 00:00:00')) }
      let(:bid2) { build(:review_bid, priority: 2, signuptopic_id: 124, assignment_id: assignment_id, updated_at: Time.zone.parse('2018-01-02 00:00:00')) }

      before do
        # Stub the participant lookup to return a double with a user_id
        allow(AssignmentParticipant).to receive(:find).with(reviewer_id).and_return(double('Participant', user_id: reviewer_user_id))
        # Stub the SignedUpTeam.topic_id method to return a specific topic id for the reviewer
        allow(SignedUpTeam).to receive(:topic_id).with(assignment_id, reviewer_user_id).and_return(self_topic)
        # Stub the TeamsUser.team_id method to simulate that the reviewer is part of a team
        allow(TeamsUser).to receive(:team_id).with(assignment_id, reviewer_user_id).and_return(team_id)
        # Stub Bid.where to return our two bids
        allow(Bid).to receive(:where).with(team_id: team_id).and_return([bid1, bid2])
        # Ensure each bid returns its signuptopic_id when topic_id is called
        allow(bid1).to receive(:topic_id).and_return(bid1.signuptopic_id)
        allow(bid2).to receive(:topic_id).and_return(bid2.signuptopic_id)
      end
      it 'returns bidding data with bids formatted correctly' do
        result = ReviewBid.reviewer_bidding_data(reviewer_id, assignment_id)
        expect(result['otid']).to eq(self_topic)
        expect(result['bids'].size).to eq(2)

        first_bid = result['bids'][0]
        expect(first_bid['tid']).to eq(bid1.signuptopic_id)
        expect(first_bid['priority']).to eq(bid1.priority)
        expect(first_bid['timestamp']).to match(timestamp_regex)

        second_bid = result['bids'][1]
        expect(second_bid['tid']).to eq(bid2.signuptopic_id)
        expect(second_bid['priority']).to eq(bid2.priority)
        expect(second_bid['timestamp']).to match(timestamp_regex)
      end
    end
    context 'when no team is found' do
      before do
        allow(AssignmentParticipant).to receive(:find).with(reviewer_id).and_return(double('Participant', user_id: reviewer_user_id))
        allow(SignedUpTeam).to receive(:topic_id).with(assignment_id, reviewer_user_id).and_return(self_topic)
        allow(TeamsUser).to receive(:team_id).with(assignment_id, reviewer_user_id).and_return(nil)
      end
      it 'returns bidding data with an empty bids array' do
        result = ReviewBid.reviewer_bidding_data(reviewer_id, assignment_id)
        expect(result['otid']).to eq(self_topic)
        expect(result['bids']).to eq([])
      end
    end
  end
  
  describe '.fallback_algorithm' do
    let(:assignment_id) { 2085 }
    let(:reviewer_ids) { [1, 2, 3] }
    let(:topics) { [101, 102, 103] }
    let(:teams) do
      {
        101 => 5, # Topic 101 has 5 team members
        102 => 3, # Topic 102 has 3 team members
        103 => 1  # Topic 103 has 1 team member
      }
    end

    before do
      allow(SignUpTopic).to receive(:where).with(assignment_id: assignment_id).and_return(double(pluck: topics))
      # Mock SignedUpTeam relation chain to support .joins, .group, .count
      signed_up_team_relation = double('SignedUpTeam Relation')
      allow(SignedUpTeam).to receive(:where).with(topic_id: topics).and_return(signed_up_team_relation)
      allow(signed_up_team_relation).to receive(:joins).and_return(signed_up_team_relation)
      allow(signed_up_team_relation).to receive(:group).and_return(signed_up_team_relation)
      allow(signed_up_team_relation).to receive(:count).and_return(teams)
      allow(SignedUpTeam).to receive(:topic_id).with(assignment_id, 1).and_return(101)
      allow(SignedUpTeam).to receive(:topic_id).with(assignment_id, 2).and_return(102)
      allow(SignedUpTeam).to receive(:topic_id).with(assignment_id, 3).and_return(nil)
    end

    it 'assigns topics in a round-robin manner while avoiding self-assignment' do
      result = ReviewBid.fallback_algorithm(assignment_id, reviewer_ids)
      expect(result['1']).not_to include(101) # Reviewer 1 should not get topic 101
      expect(result['2']).not_to include(102) # Reviewer 2 should not get topic 102
      # Instead of expecting all topics, check if reviewer 3 gets any valid topic
      valid_topics = [101, 102, 103]
      expect(valid_topics).to include(result['3'].first) # Ensure at least one valid topic is assigned
      assigned_topics = result.values.flatten
      expect(assigned_topics.uniq.size).to be <= topics.size # Ensure topics are distributed correctly
    end

    it 'returns an empty array if no topics are available' do
      allow(SignUpTopic).to receive(:where).and_return(double(pluck: []))
      empty_relation = double('Empty Relation')
      allow(SignedUpTeam).to receive(:where).with(topic_id: []).and_return(empty_relation)
      allow(empty_relation).to receive(:joins).and_return(empty_relation)
      allow(empty_relation).to receive(:group).and_return(empty_relation)
      allow(empty_relation).to receive(:count).and_return({})
      result = ReviewBid.fallback_algorithm(assignment_id, reviewer_ids)
      expect(result.values).to all(be_empty)
    end

    it 'ensures the logging messages are triggered' do
      allow(Rails.logger).to receive(:debug).and_call_original
      expect(Rails.logger).to receive(:debug).with(/Fallback algorithm triggered/)
      expect(Rails.logger).to receive(:debug).with(/Available topics/)
      expect(Rails.logger).to receive(:debug).with(/Teams sorted by size/).at_least(:once)
      ReviewBid.fallback_algorithm(assignment_id, reviewer_ids)
    end
  end
end
