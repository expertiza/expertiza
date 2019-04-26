describe GradingHistoriesController do
  describe '#index' do
    context 'when show review grading history for paticipant' do
      it 'gets history for the paticipant and renders grading_history#index page' do
        allow(GradingHistory).to receive(:where).with(grade_receiver_id: 772)
        params = {grade_receiver_id: 1, grade_type:"Submission"}
        get :index, params
        expect(response).to redirect_to('grading_histories?grade_receiver_id=1&grade_type=Submission')
      end
    end
  end
end