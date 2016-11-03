require 'rails_helper'
describe QuizResponseMap do
  #let(:quizresponsemap) {QuizResponseMap.new id: 5, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 3}
  #let(:response) {Response.new id: 4, map_id: 4}
  #let(:participant) {Participant.new id: 1}

  describe "validations" do
      before(:each) do
        @quizresponsemap = build(:quizresponsemap)
      end

      it "quizresponsemap is valid" do
        expect(@quizresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is quizresponsemap" do
        @quizresponsemap = build(:quizresponsemap)
        expect(@quizresponsemap.type).to eq("QuizResponseMap")
        expect(@quizresponsemap.type).not_to eq('Review')
        expect(@quizresponsemap.type).not_to eq('Feedback Review')
      end
      it "checks if type is quizresponsemap" do
        @participant = build(:participant)
        expect(@participant.type).to eq("AssignmentParticipant")
        expect(@participant.type).not_to eq('Review')
        expect(@participant.type).not_to eq('Participant')
      end
  end

  describe "title" do
    #test the title to be stored correctly
    it "should be Bookmark Review" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.get_title).to eq('Quiz')
    end
    it "should not be teamReview" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.get_title).not_to eq('Team Review')
    end
    it "should be feedbackReview" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.get_title).not_to eq('Feedback Review')
    end
  end


  describe "id" do
  #test all the id are stored correctly
    it "should be our exact quizresponsemap's id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.id).to eq(6)
    end
    it "should not be any other quizresponsemap's id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewee's id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.reviewee_id).not_to eq(2)
    end
    it "should be our exact reviewed_object_id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.reviewed_object_id).to eq(8)
    end
    it "should not be any other reviewed_object_id" do
      @quizresponsemap = build(:quizresponsemap)
      expect(@quizresponsemap.reviewed_object_id).not_to eq(2)
    end
  end

#  describe '#delete' do
#  	it "deletes the map" do
#      @quizresponsemap = build(:quizresponsemap)
#  		QuizResponseMap.delete(@quizresponsemap.id)
#  	  expect(QuizResponseMap.count).to eq(0)
#  	end
#  end

  describe '#get_mappings_for_reviewer' do
	  it "gives out the relation of reviewer and participant" do
      @quizresponsemap = build(:quizresponsemap)
      @participant = build(:participant)
	 	  expect(QuizResponseMap.get_mappings_for_reviewer(@participant.id).class).to eq(QuizResponseMap::ActiveRecord_Relation)
	  end
  end

  describe '#quiz_score' do
  	it "gives out the relation of reviewer and participant" do
      @quizresponsemap = build(:quizresponsemap)
  		expect(@quizresponsemap.quiz_score).to eq('N/A')		#because no quiz has been taken
  	end
  end


end
