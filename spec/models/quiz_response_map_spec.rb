require 'rails_helper'
describe QuizResponseMap do
  let(:quizresponsemap) {QuizResponseMap.new id: 5, reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 3}
  let(:response) {Response.new id: 4, map_id: 4}
  let(:participant) {Participant.new id: 1}

  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(quizresponsemap.class).to be(QuizResponseMap)
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
    it "should be our exact quiz's id" do
      expect(quizresponsemap.id).to eq(5)
    end
    it "should not be any other quiz's id" do
      expect(quizresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewer's id" do
      expect(quizresponsemap.reviewer_id).to eq(2)
    end
    it "should not be any other reviewer's id" do
      expect(quizresponsemap.reviewer_id).not_to eq(3)
    end
    it "should be our exact reviewee's id" do
      expect(quizresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(quizresponsemap.reviewee_id).not_to eq(2)
    end
    it "should be the response map_id" do
      expect(response.map_id).to eq(4)
    end
  end

  describe '#delete' do
	it "deletes the map" do
	#	expect{QuizResponseMap.delete(quizresponsemap.id)}.to change{QuizResponseMap.count}.by(-1)
	expect(QuizResponseMap.count).to eq(0)
	end
  end

  describe '#get_mappings_for_reviewer' do
	it "gives out the relation of reviewer and participant" do
		expect(QuizResponseMap.get_mappings_for_reviewer(participant.id).class).to eq(QuizResponseMap::ActiveRecord_Relation)
	end
  end

  describe '#quiz_score' do
	it "gives out the relation of reviewer and participant" do
		expect(quizresponsemap.quiz_score).to eq('N/A')		#because no quiz has been taken
	end
  end

  describe "#get_title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(quizresponsemap.get_title).to eq('Quiz')
    end
    it "should not be Review" do
      expect(quizresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Quiz Review" do
      expect(quizresponsemap.get_title).not_to eq('Quiz Review')
    end
  end
end
