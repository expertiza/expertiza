require 'rails_helper'

RSpec.describe ReviewBidsController, type: :controller do
  let(:assignment) { build(:assignment, id: 1) }
  let(:student) { build(:student) }
  let(:participant1) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 2) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:topic) { build(:topic) }
  let(:review_bid1) { build(:review_bid, id: 1, priority: 1, participant: participant1, topic: topic, assignment: assignment) }
  let(:review_bid2) { build(:review_bid, id: 2, priority: 2, participant: participant2, topic: topic, assignment: assignment) }

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
    context "when the topic is nil" do
      it "destroys the ReviewBid items" do
        post :assign_review_priority, :participant_id=>2, :topic=>nil
        expect{ReviewBid.all}.not_to include review_bid2
      end
    end

    #if there is no bid
    context "when there is no bid"
      it "creates a new ReviewBid item" do
        expect{post :assign_review_priority, :participant_id=>1, :topic=>2}.to change{ReviewBid.count}
      end

    context "when there is a bid" do
      it "should not create a new ReviewBid item" do
        expect{post :assign_review_priority, :participant_id=>1, :topic=>1}.not_to change{ReviewBid.count}
      end

      it "should update the priorities of the entries" do
        #review_priority = ReviewBid.where(participant_id:1,assignment_id:1).pluck(:priority)
        #expect{post :assign_review_priority, :participant_id=>1, :topic=>1}.to change{ReviewBid.where(participant_id:1,assignment_id:1).pluck(:priority)}.from(review_priority)
        #review_priority = ReviewBid.where(participant_id:1,assignment_id:1).pluck(:priority)
        expect{post :assign_review_priority, :participant_id=>1, :topic=>1}.to change{review_bid1}
      end
    end

  end
end
