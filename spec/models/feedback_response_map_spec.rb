require 'rails_helper'
describe FeedbackResponseMap do
  let(:feedbackresponsemap) {FeedbackResponseMap.new id: 5, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 3}
  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(feedbackresponsemap.class).to be(FeedbackResponseMap)
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
