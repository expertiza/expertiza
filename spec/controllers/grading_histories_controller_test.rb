describe GradingHistoriesController do
  describe '#index' do
    context 'when show review grading history for paticipant' do
      it 'gets history for the paticipant and renders grading_history#index page' do
        allow(GradingHistory).to receive(:where).with(grade_receiver_id: 1)
        params = {grade_receiver_id: 1}
        get :index, params
        expect(response).to redirect_to('/')
      end
    end
  end
end
