require 'rails_helper'
describe SelfReviewResponseMap do
  let(:selfreviewresponsemap) {SelfReviewResponseMap.new id: 6, reviewee_id: 1, reviewed_object_id: 8}
 


  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(selfreviewresponsemap.class).to be(SelfReviewResponseMap)
    end
  end

  describe "id" do
  #test all the id are stored correctly
  	it "should be our exact selfreviewresponsemap's id" do
      expect(selfreviewresponsemap.id).to eq(6)
    end
    it "should not be any other selfreviewresponsemap's id" do
      expect(selfreviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewee's id" do
      expect(selfreviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(selfreviewresponsemap.reviewee_id).not_to eq(2)
    end
  end

  describe "title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(selfreviewresponsemap.get_title).to eq('Self Review')
    end
    it "should not be Review" do
      expect(selfreviewresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      expect(selfreviewresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
end