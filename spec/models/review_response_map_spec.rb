require 'rails_helper'
describe ReviewResponseMap do
  let(:reviewresponsemap) {ReviewResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(reviewresponsemap.class).to be(ReviewResponseMap)
    end
  end
  describe "id" do
    it "should be our exact reviewer's id" do
      expect(reviewresponsemap.reviewer_id).to eq(2)
    end
    it "should be our exact reviewee's id" do
      expect(reviewresponsemap.reviewee_id).to eq(1)
    end
  end
  describe "title" do
    it "should be Review" do
      expect(reviewresponsemap.get_title).to eq('Review')
    end
  end
end
