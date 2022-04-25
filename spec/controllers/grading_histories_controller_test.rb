describe GradingHistoriesController do
  let(:grading_history) { build(:grading_history) }
  
  describe ':create' do
      it 'successfully creates a grading history with valid parameters' do
        expect(grading_history.grade).to eq(100)
        expect(grading_history.comment).to eq("Good work!")
        expect(grading_history.instructor_id).to eq(6)
        expect(grading_history.assignment_id).to eq(1)
        expect(grading_history.grade_receiver_id).to eq(1)
        expect(grading_history.id).to eq(1)
      end
    end
end
