require 'rails_helper'
require 'spec_helper'
describe TeammateReviewResponseMap do
  #let(:teammatereviewresponsemap) {TeammateReviewResponseMap.new id: 6, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 8}
  #teammatereviewresponsemap = create(:teammatereviewresponsemap)

  describe "validations" do
      before(:each) do
        @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      end
   
      it "teammatereviewresponsemap is valid" do
        expect(@teammatereviewresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is teammatereviewresponsemap" do
        @teammatereviewresponsemap = build(:teammatereviewresponsemap)
        expect(@teammatereviewresponsemap.type).to eq("TeammateReviewResponseMap")
        expect(@teammatereviewresponsemap.type).not_to eq('Review')
        expect(@teammatereviewresponsemap.type).not_to eq('Feedback Review')
      end
      #it "checks if type is response" do
      #  @response = build(:response)
      #  expect(@response.type).to eq("Response")
      #  expect(@response.type).not_to eq('Review')
      #  expect(@response.type).not_to eq('Feedback Review')
      #end
      it "checks if type is teammatereviewresponsemap" do
        @participant = build(:participant)
        expect(@participant.type).to eq("AssignmentParticipant")
        expect(@participant.type).not_to eq('Review')
        expect(@participant.type).not_to eq('Participant')
      end
  end


  describe "title" do
    #test the title to be stored correctly
    it "should be Bookmark Review" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.get_title).to eq('Teammate Review')
    end
    it "should not be teamReview" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.get_title).not_to eq('Team Review')
    end
    it "should be feedbackReview" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.get_title).not_to eq('Feedback Review')
    end
  end


  describe "id" do
    #test all the id are stored correctly
    it "should be our exact bookmarkratingresponsemap's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.id).to eq(6)
    end
    it "should not be any other reviewresponsemap's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      @teammatereviewresponsemap = build(:teammatereviewresponsemap)
      expect(@teammatereviewresponsemap.reviewee_id).not_to eq(2)
    end
  end

end