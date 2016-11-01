require 'rails_helper'
describe FeedbackResponseMap do
  #let(:feedbackresponsemap) {FeedbackResponseMap.new id: 5, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 3}
  #let(:response) {Response.new id: 4, map_id: 4}
  #let(:participant) {Participant.new id: 1}
  #let(:responsemap) {ResponseMap.new id:2, map_id:4, Participant: participant, reviewer_id: 2, map: 1}

  #responsemap.map = where(reviewee_id: participant.id, reviewer_id: reviewer.id)

  describe "validations" do
      before(:each) do
        @feedbackresponsemap = build(:feedbackresponsemap)
      end
   
      it "feedbackresponsemap is valid" do
        expect(@feedbackresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is feedbackresponsemap" do
        @feedbackresponsemap = build(:feedbackresponsemap)
        expect(@feedbackresponsemap.type).to eq("FeedbackResponseMap")
        expect(@feedbackresponsemap.type).not_to eq('Review')
        expect(@feedbackresponsemap.type).not_to eq('Feedback Review')
      end
      #it "checks if type is response" do
      #  @response = build(:response)
      #  expect(@response.type).to eq("Response")
      #  expect(@response.type).not_to eq('Review')
      #  expect(@response.type).not_to eq('Feedback Review')
      #end
      it "checks if type is feedbackresponsemap" do
        @participant = build(:participant)
        expect(@participant.type).to eq("AssignmentParticipant")
        expect(@participant.type).not_to eq('Review')
        expect(@participant.type).not_to eq('Participant')
      end
  end

  describe "#get_title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.get_title).to eq('Feedback')
    end
    it "should not be Review" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.get_title).not_to eq('Feedback Review')
    end
  end


  describe "id" do
    #test all the id are stored correctly
    it "should be our exact feedbackresponsemap's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.id).to eq(6)
    end
    it "should not be any other reviewresponsemap's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      @feedbackresponsemap = build(:feedbackresponsemap)
      expect(@feedbackresponsemap.reviewee_id).not_to eq(2)
    end
  end

  #describe "#show_review with response" do
  #  let(:feedbackresponsemap) {FeedbackResponseMap.new(:review => Response.new())}
  #  it "should show a review" do
  #  @feedbackresponsemap = build(:feedbackresponsemap)
  #  #  expect(feedbackresponsemap.show_review).not_to eq("No review was performed")
  #  end
  #end
  #describe "#show_review without response" do
  #  it "should show a review" do
  #    @feedbackresponsemap = build(:feedbackresponsemap)
  #    expect(feedbackresponsemap.show_review).to eq("No review was performed")
  #  end
  #end



  
end
