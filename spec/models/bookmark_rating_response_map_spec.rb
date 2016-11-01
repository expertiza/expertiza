require 'rails_helper'
describe BookmarkRatingResponseMap do
  #let(:bookmarkratingresponsemap) {BookmarkRatingResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  #let(:response) {Response.new id: 4, map_id: 4}
  #let(:participant) {Participant.new id: 1}


  describe "validations" do
      before(:each) do
        @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      end
   
      it "bookmarkratingresponsemap is valid" do
        expect(@bookmarkratingresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is bookmarkratingresponsemap" do
        @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
        expect(@bookmarkratingresponsemap.type).to eq("BookmarkRatingResponseMap")
        expect(@bookmarkratingresponsemap.type).not_to eq('Review')
        expect(@bookmarkratingresponsemap.type).not_to eq('Feedback Review')
      end
      #it "checks if type is response" do
      #  @response = build(:response)
      #  expect(@response.type).to eq("Response")
      #  expect(@response.type).not_to eq('Review')
      #  expect(@response.type).not_to eq('Feedback Review')
      #end
      it "checks if type is bookmarkratingresponsemap" do
        @participant = build(:participant)
        expect(@participant.type).to eq("AssignmentParticipant")
        expect(@participant.type).not_to eq('Review')
        expect(@participant.type).not_to eq('Participant')
      end
  end

  describe "title" do
    #test the title to be stored correctly
    it "should be Bookmark Review" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.get_title).to eq('Bookmark Review')
    end
    it "should not be teamReview" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.get_title).not_to eq('Team Review')
    end
    it "should be feedbackReview" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.get_title).not_to eq('Feedback Review')
    end
  end



  describe "id" do
    #test all the id are stored correctly
    it "should be our exact bookmarkratingresponsemap's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.id).to eq(6)
    end
    it "should not be any other reviewresponsemap's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      @bookmarkratingresponsemap = build(:bookmarkratingresponsemap)
      expect(@bookmarkratingresponsemap.reviewee_id).not_to eq(2)
    end
  end
  
  #describe "#contributor" do
  #  it "should be nil" do
  #    expect(@bookmarkratingresponsemap.contributor).to eq(nil)
  #  end
  #end
  describe "#questionnaire" do
    it "should be correct type" do
      questionnaire = build(:questionnaire)
      assignment = build(:assignment)
      #expect(bookmarkratingresponsemap.assignment.questionnaires.find_by_type('BookmarkRatingResponseMap')).to eq(sth)
    end
  end
end