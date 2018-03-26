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
  # let(:on_the_fly_calc) { build(:assignment, id: 1, name: 'Test Assgt' ) }
  let(:on_the_fly_calc) { Class.new { extend OnTheFlyCalc } }
  let(:question1) { Question.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { Question.new(id: 2, weight: 2, break_before: true) }
  let(:assignment_questionnaire) { AssignmentQuestionnaire.new(id: 1, assignment_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:questionnaire1) {build(:questionnaire, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234)}

   describe '#compute_total_score' do
     it 'computes total score for this assignment by summing the score given on all questionnaires' do
       on_the_fly_calc = Assignment.new(id: 1, name: 'Test Assgt')
       on_the_fly_calc.extend(OnTheFlyCalc)
       scores = {review1: {scores: {max: 0, min: 0, avg: nil}, assessments: [response]}}
       fake_result  = double('AssignmnetQuestionnaire')
       allow(on_the_fly_calc).to receive(:questionnaires).and_return([questionnaire1])
       #allow(ReviewQuestionnaire).to receive(:assignment_questionnaires).and_return(fake_result)
       allow(ReviewQuestionnaire).to receive_message_chain(:assignment_questionnaires, :find_by).and_return(fake_result)
       #allow(fake_result).to receive(:find_by).and_return(fake_result)
       allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: nil).and_return(double('AssignmentQuestionnaire', used_in_round: 1))
       # allow(Questionnaire).to receive(:compute_weighted_score).with()
       # allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1).and_return(assignment_questionnaire)
     # allow(Questionnaire).to receive(:compute_weighted_score).with(sy)
       expect(on_the_fly_calc.compute_total_score(scores)).to eq (0)
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
        questions = [question1]
        allow(on_the_fly_calc).to receive(:teams).and_return([team, team])
        allow(on_the_fly_calc).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(on_the_fly_calc).to receive(:num_review_rounds).and_return([])
        allow(on_the_fly_calc).to receive(:score_assignment).and_return('')
        allow(on_the_fly_calc).to receive(:total_num_of_assessments).and_return(0)
       # allow(on_the_fly_calc).to receive(:total_score).and_return(50)
       # allow(on_the_fly_calc).to receive(:index).and_return(0)
        print on_the_fly_calc.scores(questions)
      end
    end

     context 'when current assignment does not vary rubrics by round' do
       it 'computes and returns scores'
       # Write your test here!
     end
   end
 end
