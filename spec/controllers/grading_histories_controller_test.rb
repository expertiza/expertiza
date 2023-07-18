describe GradingHistoriesController do
  let(:grading_history) { build(:grading_history) }  # create a grading history object with factory girl

  describe ':create' do
    it 'successfully creates a grading history with valid parameters' do
      # validate that the grading history has the correct attributes
      expect(grading_history.grade).to eq(100)
      expect(grading_history.comment).to eq("Good work!")
      expect(grading_history.instructor_id).to eq(6)
      expect(grading_history.assignment_id).to eq(1)
      expect(grading_history.grade_receiver_id).to eq(1)
      expect(grading_history.id).to eq(1)
    end
  end

  let(:instructor) { build(:instructor, id: 6) }  # create an instructor object with factory girl
  describe '#index' do
    context 'when show review grading history for participant' do
      it 'gets history for the participant and renders grading_history#index page' do
        session = {user: instructor}  # create a session object with instructor user
        allow(GradingHistory).to receive(:create).with(instructor_id: session[:user].id,
                                                       assignment_id: 1,
                                                       grading_type: "Submission",
                                                       grade_receiver_id: 2,
                                                       grade: 100,
                                                       comment: 'comment')  # stub the create method of GradingHistory
        params = {grade_receiver_id: 2, grade_type:"Submission"}  # set request parameters for the grading history index
        get :index, params,session  # issue a GET request to the grading history index action
        expect(response).to redirect_to('grading_histories?grade_receiver_id=2&grade_type=Submission')  # validate that the response redirects to the correct page
      end
    end
  end
end
