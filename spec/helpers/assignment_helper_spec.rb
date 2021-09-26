describe AssignmentHelper do

  # E1936
  # Both AssignmentHelper#assignment_questionnaire and AssignmentHelper#questionnaire methods are removed from the
  # helpers/assignment_helper.rb since both methods contained duplicate implementation found in the different files
  # models/assignment.rb (Assignment class), models/assignment_form.rb (AssignmentForm class), and others.
  # To avoid all duplicate implementation, these methods are preserved only in the models/assignment_form.rb file and
  # tested there:
  # AssignmentForm#assignment_questionnaire
  # AssignmentForm#questionnaire

  let(:assignment_helper) { Class.new { extend AssignmentHelper } }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:questionnaire1) { build(:questionnaire, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234) }
  let(:contributor) { build(:assignment_team, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team_id: contributor.id) }

  describe '#questionnaire_options' do
    it 'throws exception if type argument nil' do
      expect { questionnaire_options(nil) }.to raise_exception(NoMethodError)
    end
  end

  describe '#compute_total_score' do
    context 'when avg score is nil' do
      it 'computes total score for this assignment by summing the score given on all questionnaires' do
        test_assignment = Assignment.new(id: 1, name: 'Test Assgt')
        scores = {review1: {scores: {max: 80, min: 0, avg: nil}, assessments: [response]}}
        allow(test_assignment).to receive(:questionnaires).and_return([questionnaire1])
        allow(ReviewQuestionnaire).to receive_message_chain(:assignment_questionnaires, :find_by)
          .with(no_args).with(assignment_id: 1).and_return(double('AssignmentQuestionnaire', id: 1))
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: nil)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
        expect(compute_total_score(test_assignment, scores)).to eq(0)
      end
    end
  end

  describe '#compute_review_hash' do
    let(:response_map) { create(:review_response_map, id: 1, reviewer_id: 1) }
    let(:response_map2) { create(:review_response_map, id: 2, reviewer_id: 2) }
    let!(:response_record) { create(:response, id: 1, response_map: response_map) }
    let!(:response_record2) { create(:response, id: 2, response_map: response_map2) }
    before(:each) do
      allow(Response).to receive(:assessment_score).and_return(50, 30)
      allow(ResponseMap).to receive(:where).and_return([response_map, response_map2])
      allow(SignedUpTeam).to receive(:find_by).with(team_id: contributor.id).and_return(signed_up_team)
    end
    context 'when current assignment varies rubrics by round' do
      it 'scores varying rubrics and returns review scores' do
        allow(assignment).to receive(:vary_by_round).and_return(true)
        allow(assignment).to receive(:rounds_of_reviews).and_return(1)
        expect(compute_reviews_hash(assignment)).to eq({})
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'scores rubrics and returns review scores' do
        allow(assignment).to receive(:vary_by_round).and_return(false)
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(double(:DueDate, round: 1))
        expect(compute_reviews_hash(assignment)).to eq(1 => {1 => 50}, 2 => {1 => 30})
      end
    end
  end

  describe '#compute_avg_and_ranges_hash' do
    before(:each) do
      score = {min: 50.0, max: 50.0, avg: 50.0}
      allow(assignment_helper).to receive(:contributors).and_return([contributor])
      allow(Response).to receive(:compute_scores).with([], [question1]).and_return(score)
      allow(ReviewResponseMap).to receive(:assessments_for).with(contributor).and_return([])
      allow(SignedUpTeam).to receive(:find_by).with(team_id: contributor.id).and_return(signed_up_team)
      allow(assignment_helper).to receive(:review_questionnaire_id).and_return(1)
    end
    context 'when current assignment varies rubrics by round' do
      it 'computes avg score and score range for each team in each round and return scores' do
        allow(assignment_helper).to receive(:vary_by_round).and_return(true)
        allow(assignment_helper).to receive(:rounds_of_reviews).and_return(1)
        expect(assignment_helper.compute_avg_and_ranges_hash).to eq(1 => {1 => {min: 50.0, max: 50.0, avg: 50.0}})
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'computes avg score and score range for each team and return scores' do
        allow(assignment_helper).to receive(:vary_by_round).and_return(false)
        expect(assignment_helper.compute_avg_and_ranges_hash).to eq(1 => {min: 50.0, max: 50.0, avg: 50.0})
      end
    end
  end
  describe '#peer_review_questions_for_team' do
    context 'when there is no signed up team' do
      it 'peer review questions should return nil' do
        val = assignment_helper.send(:peer_review_questions_for_team, nil)
        expect(val).to be_nil
      end
    end
  end


end
