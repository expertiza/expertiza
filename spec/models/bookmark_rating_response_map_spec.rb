require 'rails_helper'
describe BookmarkRatingResponseMap do
  let(:bookmarkratingresponsemap) {BookmarkRatingResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  let(:response) {Response.new id: 4, map_id: 4}
  let(:participant) {Participant.new id: 1}

  describe "#new" do
    it "should have valid parameters" do
      expect(bookmarkratingresponsemap.class).to be(BookmarkRatingResponseMap)
    end
    it "should have valid parameters" do
      expect(response.class).to be(Response)
    end
    it "should have valid parameters" do
      expect(participant.class).to be(Participant)
    end
  end

  describe "id" do
    #test all the id are stored correctly
    it "should be our exact bookmarkratingresponsemap's id" do
      expect(bookmarkratingresponsemap.id).to eq(6)
    end
    it "should not be any other reviewresponsemap's id" do
      expect(bookmarkratingresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      expect(bookmarkratingresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      expect(bookmarkratingresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      expect(bookmarkratingresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(bookmarkratingresponsemap.reviewee_id).not_to eq(2)
    end
    it "should be the response map_id" do
      expect(response.map_id).to eq(4)
    end
  end
  describe "title" do
    #test the title to be stored correctly
    it "should be Bookmark Review" do
      expect(bookmarkratingresponsemap.get_title).to eq('Bookmark Review')
    end
    it "should not be teamReview" do
      expect(bookmarkratingresponsemap.get_title).not_to eq('Team Review')
    end
    it "should be feedbackReview" do
      expect(bookmarkratingresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
  describe "#contributor" do
    it "should be nil" do
      expect(bookmarkratingresponsemap.contributor).to eq(nil)
    end
  end
  describe "#questionnaire" do
    it "should be correct type" do
      questionnaire = build(:questionnaire)
      assignment = build(:assignment)
      #expect(bookmarkratingresponsemap.assignment.questionnaires.find_by_type('BookmarkRatingResponseMap')).to eq(sth)
    end
  end
end