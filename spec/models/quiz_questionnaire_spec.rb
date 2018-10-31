describe QuizQuestionnaire do
  let(:questionnaire) { QuizQuestionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }

  describe "#valid" do
    it "returns whether the Quiz Questionnaire is valid" do
      expect(questionnaire.valid).to eq(true)
    end
  end
  
end
