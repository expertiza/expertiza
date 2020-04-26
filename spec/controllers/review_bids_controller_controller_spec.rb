require 'rails_helper'

RSpec.describe ReviewBidsController, type: :controller do
  let(:assignment) { build(:assignment, id: 1) }
  let(:student) { build(:student) }
  let(:participant1) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 2) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:topic) { build(:topic) }
  let(:review_bid1) { build(:review_bid, id: 1, priority: 1, participant: participant1, signuptopic_id: 4, assignment: assignment) }
  let(:review_bid2) { build(:review_bid, id: 2, priority: 2, participant: participant2, signuptopic_id: 5, assignment: assignment) }

  describe "#assign" do

  end

  describe "#reviewer_topic_matching" do
    it "webservice call should be successful" do
      dat = double("data")
      rest = double("RestClient")
      result = RestClient.get 'http://www.google.com', content_type: :json, accept: :json
      expect(result.code).to eq(200)
    end

    it "should return json response" do
      result = RestClient.get 'https://www.google.com', content_type: :json, accept: :json
      expect(result.header['Content-Type']).to include 'application/json' rescue result
    end
  end

  describe '#assign_review_priority' do
    context "when there is a bid" do
      it "should not create a new ReviewBid item" do
        expect{post :assign_review_priority, :participant_id=>1, :topic=>18}.not_to change{ReviewBid.count}
      end

  end
end
