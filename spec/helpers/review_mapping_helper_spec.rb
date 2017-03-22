require 'rails_helper'

describe 'ReviewMappingHelper', :type => :helper do
  describe "#construct_sentiment_query" do
    it "should not return nil" do
      expect(helper.construct_sentiment_query(1,"Text")).not_to eq(nil)
    end
  end

  describe "#get_sentiment" do
    it "should not return nil" do
      review = helper.construct_sentiment_query(1,"Test Review")
      # Test first try to get sentiment from the sentiment analysis web service
      expect(helper.get_sentiment(review, true)).not_to eq(nil)
      # Test a retry to get sentiment from the sentiment analysis web service
      expect(helper.get_sentiment(review, false)).not_to eq(nil)
    end
  end

  describe "#get_sentiment_list" do
    it "should not return nil" do
      @id=1
      @assignment = Assignment.where(id: @id)
      @reviewers = ReviewResponseMap.review_response_report(@id, @assignment, "ReviewResponseMap", nil)
      expect(helper.get_sentiment_list).not_to eq(nil)
    end
  end
end