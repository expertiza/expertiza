require 'rails_helper'
describe FeedbackResponseMap do
	before(:each) do
    @feedbackresponsemap = create(:feedbackresponsemap)
		@participant=create(:participant)
		@assignment_questionnaire= create(:assignment_questionnaire)
		@review_response=create(:review_response_map)
		@response=create(:response_take)
  end

  describe "validations" do   
      it "feedbackresponsemap is valid" do
        expect(@feedbackresponsemap).to be_valid
      end
      it "Participant is valid" do
        expect(@participant).to be_valid
      end
      it "assignment_questionnaire is valid" do
        expect(@assignment_questionnaire).to be_valid
      end
      it "review_response is valid" do
        expect(@review_response).to be_valid
      end
      it "response is valid" do
        expect(@response).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is feedbackresponsemap" do
        expect(@feedbackresponsemap.type).to eq("FeedbackResponseMap")
        expect(@participant.type).to eq("AssignmentParticipant")
        expect(@review_response.type).to eq("ReviewResponseMap")
      end
      it "Also checks the instance type" do
        expect(@feedbackresponsemap.class).to be(FeedbackResponseMap)
        expect(@participant.class).to be(Participant)
        expect(@review_response.class).to be(ReviewResponseMap)
        expect(@assignment_questionnaire.class).to be(AssignmentQuestionnaire)
        expect(@response.class).to be(Response)
      end
  end

  describe "#get_title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(@feedbackresponsemap.get_title).to eq('Feedback')
    end
    it "should not be Review" do
      expect(@feedbackresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      expect(@feedbackresponsemap.get_title).not_to eq('Feedback Review')
    end
  end


  describe "id" do
    #test all the id are stored correctly
    it "should be our exact feedbackresponsemap's id, reviewer_id and reviewee_id" do
      expect(@feedbackresponsemap.id).to eq(6)
      expect(@feedbackresponsemap.reviewer_id).to eq(2)
      expect(@feedbackresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewresponsemap's id, reviewer_id and reviewee_id" do
      expect(@feedbackresponsemap.id).not_to eq(7)
      expect(@feedbackresponsemap.reviewer_id).not_to eq(3)
      expect(@feedbackresponsemap.reviewee_id).not_to eq(2)
    end
  end

  describe "#show_review with response" do
    it "Should have a review" do
			review = build(:response_take)
      allow(FeedbackResponseMap).to receive(:review).and_return(true)
			expect(FeedbackResponseMap.review).to be(true)
    end
    it "should not show a review" do
      expect(@feedbackresponsemap.show_review).to eq("No review was performed")
    end
	end
end
