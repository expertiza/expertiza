require 'spec_helper'

describe MineReviewDataController do

  #Delete these examples and add some real ones
  it "should use MineReviewDataController" do
    controller.should be_an_instance_of(MineReviewDataController)
  end


  describe "GET 'view_review_charts'" do
    it "should be successful" do
      get 'view_review_charts'
      response.should be_success
    end
  end
end
