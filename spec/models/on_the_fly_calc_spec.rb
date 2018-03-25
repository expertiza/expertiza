describe OnTheFlyCalc do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  # You do not need to test private methods directly. These private methods should be tested when testing other public methods in the same file.
  ###

  # let(:on_the_fly_calc) { Assignment.new { extend OnTheFlyCalc } }
  let(:on_the_fly_calc) { build(:assignment, id: 1, name: 'Test Assgt' ) }
  let(:question1) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { Criterion.new(id: 2, weight: 2, break_before: true) }
  let(:review_questionnaire) { AssignmentQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:team) { build(:assignment_team) }
  let(:questionnaire1) {build(:questionnaire, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234)}

  before(:each) do
    on_the_fly_calc.extend(OnTheFlyCalc)
  end

   fdescribe '#compute_total_score' do
     it 'computes total score for this assignment by summing the score given on all questionnaires' do
  #
       questionnaires=[questionnaire1]
  #     scores = {}
  #     allow(on_the_fly_calc).to receive(:questionnaires).and_return(questionnaires)
  #     Allow(Questionnaire).to receive()
       allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: @question_id).and_return(double('AssignmentQuestionnaire', used_in_round: 1))
  #     # allow(AssignmentQuestionnaire).to receive(:assignment_questionnaires.find_by).with(assignment_id: 1).and_return(double('Questionnaire', questionnaire_weight: 100))
  #
       on_the_fly_calc.compute_total_score(scores)
    end
   end

  describe '#compute_review_hash' do
    context 'when current assignment varys rubrics by round' do
      it 'scores varying rubrics and returns review scores'
      # Write your test here!
    end

    context 'when current assignment does not vary rubrics by round' do
      it 'scores non varying rubrics and reuturn review scores'
      # Write your test here!
    end
  end

  describe '#compute_avg_and_ranges_hash' do
    context 'when current assignment varys rubrics by round' do
      it 'computes avg score and score range for each team in each round and return scores'
      # Write your test here!
    end

    context 'when current assignment does not vary rubrics by round' do
      it 'computes avg score and score range for each team and return scores'
      # Write your test here!
    end
  end

  describe '#scores' do
    context 'when current assignment varys rubrics by round' do
      it 'calculates rounds/scores/assessments and return scores' do
      expect(on_the_fly_calc).to receive()
      end
    end

    context 'when current assignment does not vary rubrics by round' do
      it 'computes and returns scores'
      # Write your test here!
    end
  end
end
