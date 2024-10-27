describe QuestionsController do
  let(:instructor) { build(:instructor, id: 6) }
  let!(:questionnaire) { create(:questionnaire, id: 1) }
  let!(:question) { create(:question, id: 1, questionnaire_id: 1) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end
  describe '#destroy' do
    context 'success' do
      it 'deletes the question' do
        request_params = { id: 1 }
        post :destroy, params: request_params
        expect(flash[:success]).to eq('You have successfully deleted the question!')
        expect(flash[:error]).to eq nil
      end

      it 'AnswerHelper.in_active_period should be called to check if this change is in the period.' do
        request_params = { id: 1 }
        expect(AnswerHelper).to receive(:in_active_period).with(1)
        post :destroy, params: request_params
      end

      it 'AnswerHelper.delete_existing_responses should be called to check if this change is in the period.' do
        request_params = { id: 1 }
        allow(AnswerHelper).to receive(:in_active_period).with(1).and_return(true)
        expect(AnswerHelper).to receive(:delete_existing_responses).with([1], 1)
        post :destroy, params: request_params
      end
    end
  end
end
