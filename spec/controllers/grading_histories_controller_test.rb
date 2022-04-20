describe GradingHistoriesController do
  let(:instructor) { build(:instructor, id: 6) }
  describe '#index' do
    context 'when show review grading history for paticipant' do
      it 'gets history for the paticipant and renders grading_history#index page' do
        session = {user: instructor}
        allow(GradingHistory).to receive(:create).with(instructor_id: session[:user].id,
                                                       assignment_id: 1,
                                                       grading_type: "Submission",
                                                       grade_receiver_id: 2,
                                                       grade: 100,
                                                       comment: 'comment')
        params = {grade_receiver_id: 2, grade_type:"Submission"}
        get :index, params,session
        expect(response).to redirect_to('grading_histories?grade_receiver_id=2&grade_type=Submission')
      end
    end
  end
end
