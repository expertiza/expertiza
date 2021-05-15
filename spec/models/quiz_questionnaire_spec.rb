describe QuizQuestionnaire do 
   let(:quiz_questionnaire) { QuizQuestionnaire.new }
   let(:quiz_response_map) {build (:quiz_response_map)}
   describe '#symbol' do
     it 'returns the quiz symbol' do
       expect(quiz_questionnaire.symbol).to eq("quiz".to_sym)
     end
   end

end