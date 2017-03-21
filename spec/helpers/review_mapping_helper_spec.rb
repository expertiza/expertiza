require 'rails_helper'

describe 'ReviewMappingHelper', :type => :helper do
  describe "#construct_sentiment_query" do
    it "should not return nil" do
      helper.construct_sentiment_query(1,"Text").should_not be_nil
    end
  end
end