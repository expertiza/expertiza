describe QuestionsController do
  let(:instructor) { build(:instructor, id: 6) }
  let!(:itemnaire) { create(:itemnaire, id: 1) }
  let!(:item) { create(:item, id: 1, itemnaire_id: 1) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end
  describe '#destroy' do
    context 'success' do
      it 'deletes the item' do
        request_params = { id: 1 }
        post :destroy, params: request_params
        expect(flash[:success]).to eq('You have successfully deleted the item!')
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
