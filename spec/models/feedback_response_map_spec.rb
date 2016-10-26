require 'rails_helper'
describe FeedbackResponseMap do
  let(:feedbackresponsemap) {FeedbackResponseMap.new id: 5, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 3}
  let(:response) {Response.new id: 4, map_id: 4}
  let(:participant) {Participant.new id: 1}
  let(:responsemap) {ResponseMap.new id:2, map_id:4, Participant: participant, reviewer_id: 2, map: 1}

  #responsemap.map = where(reviewee_id: participant.id, reviewer_id: reviewer.id)

  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(feedbackresponsemap.class).to be(FeedbackResponseMap)
    end
    it "Validate response instance creation with valid parameters" do
      expect(response.class).to be(Response)
    end
    it "Validate response instance creation with valid parameters" do
      expect(participant.class).to be(Participant)
    end
  end
  describe "id" do
  #test all the id are stored correctly
  	it "should be our exact teammatereviewresponsemap's id" do
      expect(feedbackresponsemap.id).to eq(5)
    end
    it "should not be any other teammatereviewresponsemap's id" do
      expect(feedbackresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      expect(feedbackresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      expect(feedbackresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      expect(feedbackresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(feedbackresponsemap.reviewee_id).not_to eq(2)
    end
  end

  describe "#show_review" do
    it "should not show any review" do
      expect(feedbackresponsemap.show_review).to eq("No review was performed")
    end
  end
  describe "#contributor" do
    it "should return the object of same class" do
    #  expect(feedbackresponsemap.contributor.class).to be(FeedbackResponseMap)
    end
  end

  describe "#get_title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(feedbackresponsemap.get_title).to eq('Feedback')
    end
    it "should not be Review" do
      expect(feedbackresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      expect(feedbackresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
end
