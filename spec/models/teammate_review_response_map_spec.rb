require 'rails_helper'
require 'spec_helper'
describe TeammateReviewResponseMap do
  let(:teammatereviewresponsemap) {TeammateReviewResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  #teammatereviewresponsemap = create(:teammatereviewresponsemap)


  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(teammatereviewresponsemap.class).to be(TeammateReviewResponseMap)
    end
  end

  describe "id" do
  #test all the id are stored correctly
  	it "should be our exact teammatereviewresponsemap's id" do
      expect(teammatereviewresponsemap.id).to eq(6)
    end
    it "should not be any other teammatereviewresponsemap's id" do
      expect(teammatereviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      expect(teammatereviewresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      expect(teammatereviewresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      expect(teammatereviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(teammatereviewresponsemap.reviewee_id).not_to eq(2)
    end
  end

  describe "title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(teammatereviewresponsemap.get_title).to eq('Teammate Review')
    end
    it "should not be Review" do
      expect(teammatereviewresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      expect(teammatereviewresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
end