describe 'QuizResponseMap' do
  describe '#quiz_score' do
    it 'should return N/A when no answer' do
      @questionnaire = create(:quizquestionnaire, id: 1)
      @question1 = create(:question, id: 1, questionnaire: @questionnaire)
      @question2 = create(:question, id: 2, questionnaire: @questionnaire)
      @response1 = create(:response, id: 1)
      @response2 = create(:response, id: 2)
      Answer.create response_id: 1, question_id: 1
      Answer.create response_id: 2, question_id: 2
      @quiz_response_map = create(:quizresponse_map, quiz_questionnaire: @questionnaire)
      expect(@quiz_response_map.quiz_score).to eql "N/A"
    end
  end
end