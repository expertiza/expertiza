describe Bid do
  let(:assignment) { create(:assignment, is_intelligent: true, name: 'assignment') }

  let(:topic1) { create(:topic, assignment_id: assignment.id) }
  let(:topic2) { create(:topic, assignment_id: assignment.id) }
  let(:topic3) { create(:topic, assignment_id: assignment.id) }
  let(:topic4) { create(:topic, assignment_id: assignment.id) }

  let(:assignment_team) { create(:assignment_team, parent_id: assignment.id) }

  before :each do
    topic1.save
    topic2.save
    topic3.save
    topic4.save
  end

  describe '#merge_bids_from_different_previous_teams' do
    it 'should create bids objects of the newly-merged team on each sign-up topics' do
      bid_count = Bid.count
      team_id = assignment_team.id
      user_bidding_info = [[1, 0, 2, 2], [2, 1, 3, 0], [3, 2, 1, 1]]
      Bid.merge_bids_from_different_users(team_id, assignment.sign_up_topics, user_bidding_info)
      expect(Bid.count).to eq(bid_count + 4)
      expect(Bid.find_by(topic_id: 1, team_id: team_id, priority: 1)).to_not be nil
      expect(Bid.find_by(topic_id: 2, team_id: team_id, priority: 3)).to_not be nil
      expect(Bid.find_by(topic_id: 3, team_id: team_id, priority: 2)).to_not be nil
      expect(Bid.find_by(topic_id: 4, team_id: team_id, priority: 4)).to_not be nil
      expect(Bid.find_by(topic_id: 1, team_id: team_id, priority: 2)).to be nil
    end
  end
end
