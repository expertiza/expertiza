describe QuestionsController do
  let(:question) {build(:question, id: 1, questionnaire_id: 1)}

  describe '#destroy' do
    context 'success' do
      it 'deletes the question' do
	      # params = {id: 1}
        # post :destroy,params
        # expect(flash[:success]).to eq("You have successfully deleted the question!")
      end
    end

    context 'when params[:add_new_questions] is not nil.' do
      it 'AnswerHelper.in_active_period should be called to check if this change is in the period.' do
        params = {id: 1}
        Question.where(questionnaire_id: questionnaire_id).ids
        allow(Question).to receive(:find).with('1').and_return(question)
        allow(Question).to receive(:where).with('1').and_return([question])
        expect(AnswerHelper).to receive(:in_active_period).with('1')
        post :destroy,params
      end
    end

    context 'when params[:add_new_questions] is not nil and the change is in the period.' do
      it 'AnswerHelper.delete_existing_responses should be called to check if this change is in the period.' do
        # params = {id: 1}
        # allow(AnswerHelper).to receive(:in_active_period).with('1').and_return(true)
        # expect(AnswerHelper).to receive(:delete_existing_responses).with('1', [])
        # post :destroy,params
      end
    end
  end
end