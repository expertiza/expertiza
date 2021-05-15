describe QuizQuestionnaire do 
   let(:quiz_questionnaire) {build (:quiz_questionnaire)}
   let(:quiz_response_map) {build (:quiz_response_map)}
   describe '#symbol' do
     expect(quiz_questionnaire.symbol).to eq("quiz".to_sym)
   end

end