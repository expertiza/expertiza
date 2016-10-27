require 'rails_helper'
describe ReviewResponseMap do
  let(:reviewresponsemap) {ReviewResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  let(:response) {Response.new id: 4, map_id: 4}
  let(:participant) {Participant.new id: 1}

  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(reviewresponsemap.class).to be(ReviewResponseMap)
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
    it "should be our exact reviewresponsemap's id" do
      expect(reviewresponsemap.id).to eq(6)
    end
    it "should not be any other reviewresponsemap's id" do
      expect(reviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      expect(reviewresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      expect(reviewresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      expect(reviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(reviewresponsemap.reviewee_id).not_to eq(2)
    end
    it "should be the response map_id" do
      expect(response.map_id).to eq(4)
    end
  end
  describe "title" do
  #test the title to be stored correctly
    it "should be Review" do
      expect(reviewresponsemap.get_title).to eq('Review')
    end
    it "should not be teamReview" do
      expect(reviewresponsemap.get_title).not_to eq('Team Review')
    end
    it "should be feedbackReview" do
      expect(reviewresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
  describe "#export_field" do
    it "should be xx" do
	expect(ReviewResponseMap.export_fields(6)).to eq(["contributor", "reviewed by"])
    end
  end
  describe "#show_feedback" do
    let(:reviewresponsemap) {ReviewResponseMap.new(:response => [Response.new(:id => 4)])}
#    let(:response) {Response.new(:id => 4)}
    it "should do something" do
    #  expect(reviewresponsemap.show_feedback(reviewresponsemap.response)).to eq(200)
    end
  end
  describe '#delete' do
    let(:reviewresponsemap) {ReviewResponseMap.new(:id => 8, :reviewee_id => 1, :reviewer_id => 2, :reviewed_object_id => 8, :response => [Response.new(:id => 8)])}
    let(:response) {Response.new(:id => 1, :map_id => 1)}
    let(:feedbackresponsemap) {FeedbackResponseMap.new(:id => 2, :reviewed_object_id => 8)}
    let(:metareviewresponsemap) {MetaReviewResponseMap.new(:id => 8, :reviewed_object_id => 8)}
	it "deletes the map" do
		expect(ReviewResponseMap.count).to eq(0)
#		expect{ReviewResponseMap.delete(reviewresponsemap)}.to change{ReviewResponseMap.count}.by(-1)
	end
  end



end
