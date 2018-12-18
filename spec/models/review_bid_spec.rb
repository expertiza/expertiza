require 'spec_helper'
describe 'ReviewBid' do
  let(:ass) { build(:assignment, id: 1, name: 'test assignment_team') }
  let(:user) { build(:student, id: 1, name: 'peter', fullname: 'peter') }
  let(:par) { build(:participant, id: 1, parent_id: 1, user_id: 1) }
  describe "#get_rank_by_participant" do
    context "if the participant has not set bidding yet" do
      it "return the team list with random order" do
        team1 = build(:signed_up_team, id: 1, team_id: 1)
        team2 = build(:signed_up_team, id: 1, team_id: 2)
        allow(ReviewBid).to receive(:order).and_return([])
        expect(ReviewBid.get_rank_by_participant(par, [team1, team2].map(&:team_id))).to eq([1, 2]) | eq([2, 1])
      end
    end
    context "the participant has set bidding" do
      it "return bid item ordered by priority" do
        bid1 = build(:review_bid, team_id: 1, participant_id: 1, priority: 2)
        bid2 = build(:review_bid, team_id: 2, participant_id: 1, priority: 1)
        allow(ReviewBid).to receive_message_chain(:where, :order).and_return([bid2, bid1])
        expect(ReviewBid.get_rank_by_participant(par, [1, 2])).to eq([2, 1])
      end
      it "with different priority" do
        bid1 = build(:review_bid, team_id: 1, participant_id: 1, priority: 2)
        bid2 = build(:review_bid, team_id: 2, participant_id: 1, priority: 1)
        bid3 = build(:review_bid, team_id: 3, participant_id: 1, priority: 3)
        allow(ReviewBid).to receive_message_chain(:where, :order).and_return([bid2, bid1, bid3])
        expect(ReviewBid.get_rank_by_participant(par, [1, 2, 3])).to eq([2, 1, 3])
      end
    end
  end
  describe "get_bids_by_participant" do
    context "the participant has set bidding" do
      it "return full information about a bid including team name, rank, topic" do
        topic1 = build(:topic, id: 1, topic_name: "topic 1", topic_identifier: "E1")
        topic2 = build(:topic, id: 2, topic_name: "topic 2", topic_identifier: "E2")
        topic3 = build(:topic, id: 3, topic_name: "topic 3", topic_identifier: "E3")
        allow(SignUpTopic).to receive(:where).and_return([topic1, topic2, topic3])
        steam1 = build(:signed_up_team, id: 1, team_id: 1, topic_id: 1)
        steam2 = build(:signed_up_team, id: 2, team_id: 2, topic_id: 2)
        steam3 = build(:signed_up_team, id: 3, team_id: 3, topic_id: 3)
        allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: 0).and_return([steam1])
        allow(SignedUpTeam).to receive(:where).with(topic_id: 2, is_waitlisted: 0).and_return([steam2])
        allow(SignedUpTeam).to receive(:where).with(topic_id: 3, is_waitlisted: 0).and_return([steam3])
        bid1 = build(:review_bid, team_id: 1, participant_id: 1, priority: 2)
        bid2 = build(:review_bid, team_id: 2, participant_id: 1, priority: 1)
        bid3 = build(:review_bid, team_id: 3, participant_id: 1, priority: 3)
        allow(ReviewBid).to receive_message_chain(:where, :order).and_return([bid2, bid1, bid3])
        ateam1 = build(:assignment_team, id: 1, name: "team 1")
        ateam2 = build(:assignment_team, id: 2, name: "team 2")
        ateam3 = build(:assignment_team, id: 3, name: "team 3")
        allow(Team).to receive(:where).and_return([ateam1, ateam2, ateam3])
        bid_info = ReviewBid.get_bids_by_participant(par)
        expect(bid_info.length).to eq(3)
        expect(bid_info[0].bid_topic_name).to eq("topic 2")
        expect(bid_info[0].bid_topic_identifier).to eq("E2")
        expect(bid_info[0].bid_team_name).to eq("team 2")
      end
    end
  end
end
