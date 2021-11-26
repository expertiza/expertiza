describe FeedbackScoreCalc do
  let(:feedback_score_calc) { Class.new { extend FeedbackScoreCalc } }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assignment', rounds_of_reviews: 1) }

  describe '#compute_author_feedback_scores' do
    let(:response_map) { create(:review_response_map, id: 1, reviewer_id: 1, reviewee_id: 2) }
    let(:response) { create(:response, id: 1)}
    let(:answer) {create(:answer, question_id: 1)}
    let(:question) {create(:question, id: 1, questionnaire_id: 5)}
    before(:each) do
      allow(assignment).to receive(:num_review_rounds).and_return(1)
      allow(ResponseMap).to receive(:where).and_return([response_map])
      allow(Response).to receive(:where).and_return([response])
      allow(Answer).to receive(:where).and_return([answer])
      allow(Question).to receive(:find).with(1).and_return(question)
      allow(Question).to receive(:where).and_return([question])
      allow(Response).to receive(:assessment_score).and_return(80)

      expect(assignment.compute_author_feedback_scores).to eq({1 => {1 => {'2': 80}}})
    end
  end
end