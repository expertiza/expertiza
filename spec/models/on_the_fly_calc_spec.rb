describe OnTheFlyCalc do
  let(:on_the_fly_calc) { Class.new { extend OnTheFlyCalc } }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:questionnaire1) { build(:questionnaire, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234) }
  let(:contributor) { build(:assignment_team, id: 1) }

  describe '#compute_total_score' do
    context 'when avg score is nil' do
      it 'computes total score for this assignment by summing the score given on all questionnaires' do
        on_the_fly_calc = Assignment.new(id: 1, name: 'Test Assgt')
        scores = {review1: {scores: {max: 80, min: 0, avg: nil}, assessments: [response]}}
        allow(on_the_fly_calc).to receive(:questionnaires).and_return([questionnaire1])
        allow(ReviewQuestionnaire).to receive_message_chain(:assignment_questionnaires, :find_by)
          .with(no_args).with(assignment_id: 1).and_return(double('AssignmentQuestionnaire', id: 1))
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: nil)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
        expect(on_the_fly_calc.compute_total_score(scores)).to eq(0)
      end
    end
  end

  describe '#compute_review_hash' do
    let(:response_map) { create(:review_response_map, id: 1, reviewer_id: 1) }
    let(:response_map2) { create(:review_response_map, id: 2, reviewer_id: 2) }
    let!(:response_record) { create(:response, id: 1, response_map: response_map) }
    let!(:response_record2) { create(:response, id: 2, response_map: response_map2) }
    before(:each) do
      allow(Answer).to receive(:get_total_score).and_return(50, 30)
      allow(ResponseMap).to receive(:where).and_return([response_map, response_map2])
    end
    context 'when current assignment varys rubrics by round' do
      it 'scores varying rubrics and returns review scores' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(assignment).to receive(:rounds_of_reviews).and_return(1)
        expect(assignment.compute_reviews_hash).to eql({})
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'scores varying rubrics and returns review scores' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(double(:DueDate, round: 1))
        expect(assignment.compute_reviews_hash).to eql(1 => {1 => 50}, 2 => {1 => 30})
      end
    end
  end

  describe '#compute_avg_and_ranges_hash' do
    before(:each) do
      score = {min: 50.0, max: 50.0, avg: 50.0}
      allow(on_the_fly_calc).to receive(:contributors).and_return([contributor])
      allow(Answer).to receive(:compute_scores).with([], [question1]).and_return(score)
      allow(ReviewResponseMap).to receive(:get_assessments_for).with(contributor).and_return([])
      allow(on_the_fly_calc).to receive(:review_questionnaire_id).and_return(1)
    end
    context 'when current assignment varys rubrics by round' do
      it 'computes avg score and score range for each team in each round and return scores' do
        allow(on_the_fly_calc).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(on_the_fly_calc).to receive(:rounds_of_reviews).and_return(1)
        expect(on_the_fly_calc.compute_avg_and_ranges_hash).to eq(1 => {1 => {min: 50.0, max: 50.0, avg: 50.0}})
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'computes avg score and score range for each team and return scores' do
        allow(on_the_fly_calc).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(on_the_fly_calc.compute_avg_and_ranges_hash).to eq(1 => {min: 50.0, max: 50.0, avg: 50.0})
      end
    end
  end
end
