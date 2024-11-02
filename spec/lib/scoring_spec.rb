describe Scoring do
  include Scoring
  let(:assignment_helper) { Class.new { extend AssignmentHelper } }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:questionnaire1) { build(:questionnaire, name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234) }
  let(:contributor) { build(:assignment_team, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team_id: contributor.id) }

  # ReviewResponseMap Spec Additions
  let(:student) { build(:student, id: 1, username: 'name', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:response3) { build(:response) }
  let(:question) { double('Question') }

  describe '#compute_total_score' do
    context 'when avg score is nil' do
      it 'computes total score for this assignment by summing the score given on all questionnaires' do
        scores = { review1: { scores: { max: 80, min: 0, avg: nil }, assessments: [response] } }
        allow(assignment).to receive(:questionnaires).and_return([questionnaire1])
        allow(ReviewQuestionnaire).to receive_message_chain(:assignment_questionnaires, :find_by)
          .with(no_args).with(assignment_id: 1).and_return(double('AssignmentQuestionnaire', id: 1))
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: nil)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
        expect(compute_total_score(assignment, scores)).to eq(0)
      end
    end
  end

  describe '#compute_review_hash' do
    let(:response_map) { create(:review_response_map, id: 1, reviewer_id: 1) }
    let(:response_map2) { create(:review_response_map, id: 2, reviewer_id: 2) }
    let!(:response_record) { create(:response, id: 1, response_map: response_map) }
    let!(:response_record2) { create(:response, id: 2, response_map: response_map2) }
    before(:each) do
      allow_any_instance_of(Scoring).to receive(:assessment_score).and_return(50, 30)
      allow(ResponseMap).to receive(:where).and_return([response_map, response_map2])
      allow(SignedUpTeam).to receive(:find_by).with(team_id: contributor.id).and_return(signed_up_team)
    end
    context 'when current assignment varies rubrics by round' do
      it 'scores varying rubrics and returns review scores' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(assignment).to receive(:rounds_of_reviews).and_return(1)
        expect(compute_reviews_hash(assignment)).to eq({1=>{1=>{1=>50}}, 2=>{1=>{1=>30}}})
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'scores rubrics and returns review scores' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(double(:DueDate, round: 1))
        expect(compute_reviews_hash(assignment)).to eq(1 => { 1 => 50 }, 2 => { 1 => 30 })
      end
    end
  end

  describe '#compute_avg_and_ranges_hash' do
    before(:each) do
      score = { min: 50.0, max: 50.0, avg: 50.0 }
      allow(assignment_helper).to receive(:contributors).and_return([contributor])
      allow_any_instance_of(Scoring).to receive(:aggregate_assessment_scores).with([], [question1]).and_return(score)
      allow(ReviewResponseMap).to receive(:assessments_for).with(contributor).and_return([])
      allow(SignedUpTeam).to receive(:find_by).with(team_id: contributor.id).and_return(signed_up_team)
      allow(assignment_helper).to receive(:review_questionnaire_id).and_return(1)
      allow_any_instance_of(Scoring).to receive(:peer_review_questions_for_team).and_return([question1])
    end
    context 'when current assignment varies rubrics by round' do
      it 'computes avg score and score range for each team in each round and return scores' do
        allow(assignment_helper).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(assignment_helper).to receive(:rounds_of_reviews).and_return(1)
        expect(compute_avg_and_ranges_hash(assignment_helper)).to eq(1 => { 1 => { min: 50.0, max: 50.0, avg: 50.0 } })
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'computes avg score and score range for each team and return scores' do
        allow(assignment_helper).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(compute_avg_and_ranges_hash(assignment_helper)).to eq(1 => { min: 50.0, max: 50.0, avg: 50.0 })
      end
    end
  end

  describe '#peer_review_questions_for_team' do
    context 'when there is no signed up team' do
      it 'peer review questions should return nil' do
        val = Scoring.send(:peer_review_questions_for_team, nil, nil)
        expect(val).to be_nil
      end
    end
  end

  describe '#participant_scores' do
    before(:each) do
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                         .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
      allow(questionnaire).to receive(:symbol).and_return(:review)
      allow(questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([response3])
      allow_any_instance_of(Scoring).to receive(:aggregate_assessment_scores).with([response3], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(ResponseMap).to receive(:compute_total_score).with(assignment, any_args).and_return(100)
      allow(assignment).to receive(:questionnaires).and_return([questionnaire])
      allow(participant).to receive(:assignment).and_return(assignment)
      allow(response3).to receive(:id).and_return(nil)
    end
    context 'when assignment is not varying rubric by round and not an microtask' do
      it 'calculates scores that this participant has been given' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(ResponseMap.participant_scores(participant, review1: [question]).inspect).to eq('{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, '\
          'user_id: 1, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, '\
          'type: "AssignmentParticipant", handle: "handle", time_stamp: nil, digital_signature: nil, duty: nil, '\
          'can_take_quiz: true, Hamer: 1.0, Lauw: 0.0, duty_id: nil, can_mentor: false>, :review1=>{:assessments=>[#<Response id: nil, '\
          'map_id: 1, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, '\
          'is_submitted: false, visibility: "private">], :scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100}')
      end
    end

    context 'when assignment is varying rubric by round but not an microtask' do
      it 'calculates scores that this participant has been given' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        expect(ResponseMap.participant_scores(participant, review1: [question]).inspect).to eq('{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, '\
          'user_id: 1, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, '\
          'type: "AssignmentParticipant", handle: "handle", time_stamp: nil, digital_signature: nil, duty: nil, '\
          'can_take_quiz: true, Hamer: 1.0, Lauw: 0.0, duty_id: nil, can_mentor: false>, :review1=>{:assessments=>[#<Response id: nil, '\
          'map_id: 1, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, '\
          'is_submitted: false, visibility: "private">], :scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100, '\
          ':review=>{:assessments=>[#<Response id: nil, map_id: 1, additional_comment: nil, created_at: nil, '\
          'updated_at: nil, version_num: nil, round: 1, is_submitted: false, visibility: "private">], '\
          ':scores=>{:max=>95, :min=>88, :avg=>90.0}}}')
      end
    end

    context 'when assignment is not varying rubric by round but an microtask' do
      it 'calculates scores that this participant has been given' do
        assignment.microtask = true
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(SignUpTopic).to receive(:find_by).with(assignment_id: 1).and_return(double('SignUpTopic', micropayment: 66))
        expect(ResponseMap.participant_scores(participant, review1: [question]).inspect).to eq('{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, '\
          'user_id: 1, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, '\
          'type: "AssignmentParticipant", handle: "handle", time_stamp: nil, digital_signature: nil, duty: nil, '\
          'can_take_quiz: true, Hamer: 1.0, Lauw: 0.0, duty_id: nil, can_mentor: false>, :review1=>{:assessments=>[#<Response id: nil, '\
          'map_id: 1, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, '\
          'is_submitted: false, visibility: "private">], :scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100, '\
          ':max_pts_available=>66}')
      end
    end
  end

  describe '#compute_assignment_score' do
    before(:each) do
      allow(questionnaire).to receive(:symbol).and_return(:review)
      allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
      allow(assignment).to receive(:questionnaires).and_return([questionnaire])
      allow(participant).to receive(:assignment).and_return(assignment)
    end

    context 'when the round of questionnaire is nil' do
      it 'record the result as review scores' do
        scores = {}
        question_hash = { review: question }
        score_map = { max: 100, min: 100, avg: 100 }
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: nil))
        allow(questionnaire).to receive(:get_assessments_for).with(participant).and_return([response3])
        allow_any_instance_of(Scoring).to receive(:aggregate_assessment_scores).with(any_args).and_return(score_map)
        ResponseMap.compute_assignment_score(participant, question_hash, scores)
        expect(scores[:review][:assessments]).to eq([response3])
        expect(scores[:review][:scores]).to eq(score_map)
      end
    end

    context 'when the round of questionnaire is not nil' do
      it 'record the result as review#{n} scores' do
        scores = {}
        question_hash = { review: question }
        score_map = { max: 100, min: 100, avg: 100 }
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
        allow(questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([response3])
        allow_any_instance_of(Scoring).to receive(:aggregate_assessment_scores).with(any_args).and_return(score_map)
        ResponseMap.compute_assignment_score(participant, question_hash, scores)
        expect(scores[:review1][:assessments]).to eq([response3])
        expect(scores[:review1][:scores]).to eq(score_map)
      end
    end
  end

  describe '#merge_scores' do
    context 'when all of the review_n are nil' do
      it 'set max, min, avg of review score as 0' do
        allow(participant).to receive(:assignment).and_return(assignment)
        scores = {}
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        merge_scores(participant, scores)
        expect(scores[:review][:scores][:max]).to eq(0)
        expect(scores[:review][:scores][:min]).to eq(0)
        expect(scores[:review][:scores][:min]).to eq(0)
      end
    end

    context 'when the review_n is not nil' do
      it 'merge the score of review_n to the score of review' do
        allow(participant).to receive(:assignment).and_return(assignment)
        score_map = { max: 100, min: 100, avg: 100 }
        scores = { review1: { scores: score_map, assessments: [response] } }
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        merge_scores(participant, scores)
        expect(scores[:review][:scores][:max]).to eq(100)
        expect(scores[:review][:scores][:min]).to eq(100)
        expect(scores[:review][:scores][:min]).to eq(100)
      end
    end
  end
  describe '#update_max_or_min' do
    context 'test updating the max' do
      it 'should not update the max if :max is nil' do
        scores = { round1: { scores: { max: nil } }, review: { scores: { max: 90 } } }
        # Scores[:review][:scores][:max] should not change to nil (currently 90)
        ResponseMap.update_max_or_min(scores, :round1, :review, :max)
        expect(scores[:review][:scores][:max]).to eq(90)
      end

      it 'should update the review max score to the round max score if round was higher' do
        scores = { round1: { scores: { max: 90 } }, review: { scores: { max: 80 } } }
        ResponseMap.update_max_or_min(scores, :round1, :review, :max)
        expect(scores[:review][:scores][:max]).to eq(90)
      end

      it 'review max score should be unchanged if round max score is less than review max score' do
        scores = { round1: { scores: { max: 70 } }, review: { scores: { max: 80 } } }
        ResponseMap.update_max_or_min(scores, :round1, :review, :max)
        expect(scores[:review][:scores][:max]).to eq(80)
      end
    end
    context 'test updating the min' do
      it 'should not update the min if :min is nil' do
        scores = { round1: { scores: { min: nil } }, review: { scores: { min: 90 } } }
        # Scores[:review][:scores][:max] should not change to nil (currently 90)
        ResponseMap.update_max_or_min(scores, :round1, :review, :min)
        expect(scores[:review][:scores][:min]).to eq(90)
      end

      it 'update the review min score to the round min score if round was less' do
        scores = { round1: { scores: { min: 20 } }, review: { scores: { min: 30 } } }
        ResponseMap.update_max_or_min(scores, :round1, :review, :min)
        expect(scores[:review][:scores][:min]).to eq(20)
      end

      it 'review min score should be unchanged if round min score greater than the review min score' do
        scores = { round1: { scores: { min: 60 } }, review: { scores: { min: 20 } } }
        ResponseMap.update_max_or_min(scores, :round1, :review, :min)
        expect(scores[:review][:scores][:min]).to eq(20)
      end
    end
  end
  describe '#aggregate_assessment_scores' do
    let(:response1) { double('respons1') }
    let(:response2) { double('respons2') }

    before(:each) do
      @total_score = 100.0
      allow_any_instance_of(Scoring).to receive(:assessment_score).and_return(@total_score)
    end

    it 'returns nil if list of assessments is empty' do
      assessments = []
      scores = aggregate_assessment_scores(assessments, [question1])
      expect(scores[:max]).to eq nil
      expect(scores[:min]).to eq nil
      expect(scores[:avg]).to eq nil
    end

    it 'returns scores when a single valid assessment of total score 100 is give' do
      assessments = [response1]
      scores = aggregate_assessment_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq @total_score
    end

    it 'returns scores when two valid assessments of total scores 80 and 100 are given' do
      assessments = [response1, response2]
      total_score1 = 100.0
      total_score2 = 80.0
      allow_any_instance_of(Scoring).to receive(:assessment_score).and_return(total_score1, total_score2)
      scores = aggregate_assessment_scores(assessments, [question1])
      expect(scores[:max]).to eq total_score1
      expect(scores[:min]).to eq total_score2
      expect(scores[:avg]).to eq (total_score1 + total_score2) / 2
    end
  end
  describe '#test get total score' do
    it 'returns total score when required conditions are met' do
      # stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
      allow(ScoreView).to receive(:questionnaire_data).and_return(double('scoreview', weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4))
      allow(Answer).to receive(:where).and_return([double('row1', question_id: 1, answer: '1')])
      expect(assessment_score(response: [response], questions: [question1])).to eq 100.0
      # output calculation is (weighted_score / (sum_of_weights * max_question_score)) * 100
      # 4.0
    end

    it 'returns total score when one answer is nil for scored question and its weight gets removed from sum_of_weights' do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double('scoreview', weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4))
      allow(Answer).to receive(:where).and_return([double('row1', question_id: 1, answer: nil)])
      expect(assessment_score(response: [response], questions: [question1])).to be_within(0.01).of(125.0)
    end

    it 'returns -1 when answer is nil for scored question which makes sum of weights = 0' do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double('scoreview', weighted_score: 20, sum_of_weights: 1, q1_max_question_score: 5))
      allow(Answer).to receive(:where).and_return([double('row1', question_id: 1, answer: nil)])
      expect(assessment_score(response: [response], questions: [question1])).to eq -1.0
    end

    it 'returns -1 when weighted_score of questionnaireData is nil' do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double('scoreview', weighted_score: nil, sum_of_weights: 5, q1_max_question_score: 5))
      allow(Answer).to receive(:where).and_return([double('row1', question_id: 1, answer: nil)])
      expect(assessment_score(response: [response], questions: [question1])).to eq -1.0
    end
  end
end
