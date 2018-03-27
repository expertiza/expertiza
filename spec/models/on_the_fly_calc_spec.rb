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
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:question2) { Criterion.new(id: 2, weight: 2, break_before: true) }
  let(:question3) { Criterion.new(id: 3, weight: 2, break_before: true) }
  let(:assignment_questionnaire) { double('AssignmnetQuestionnaire',id: 1, assignment_id: 1,questionnaire_weight: 200) }
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
      scores = {review1: {scores: {max: 80, min: 0, avg: nil}, assessments: [response]}}
      fake_result  = double('AssignmnetQuestionnaire')
      allow(on_the_fly_calc).to receive(:questionnaires).and_return([questionnaire1])
      allow(ReviewQuestionnaire).to receive_message_chain(:assignment_questionnaires,:find_by).with(no_args).with(assignment_id: 1).and_return(assignment_questionnaire)
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: nil).and_return(double('AssignmentQuestionnaire', used_in_round: 1))
      expect(on_the_fly_calc.compute_total_score(scores)).to eq(0)
    end
  end

  describe '#compute_review_hash' do
    context 'when current assignment varys rubrics by round' do
      let(:questionnaire) { create(:questionnaire, id: 1) }
      let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
      let(:question2) { create(:question, questionnaire: questionnaire, weight: 2, id: 2) }

      let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1, reviewer_id: 1) }
      let(:response_map2) { create(:review_response_map, id: 2, reviewed_object_id: 1, reviewer_id: 2) }

      let!(:response_record) { create(:response, id: 1, response_map: response_map) }
      let!(:response_record2) { create(:response, id: 2, response_map: response_map2) }

      let!(:answer) { create(:answer, question: question1, response_id: 1) }
      let(:assignment) { build(:assignment, id: 1) }

      let(:response1) { double("respons1") }
      let(:response2) { double("respons2") }

      before(:each) do
        @total_score = 50.0
        allow(Answer).to receive(:get_total_score).and_return(50,30)
      end

      it 'scores varying rubrics and returns review scores' do
        allow(ResponseMap).to receive(:where).and_return([response_map, response_map2])
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(TRUE)
        allow(assignment).to receive(:rounds_of_reviews).and_return(1)
        temp = assignment.compute_reviews_hash()
        expect(temp).to eql({})
      end
    end

    context 'when current assignment does not vary rubrics by round' do
      let(:questionnaire) { create(:questionnaire, id: 1) }
      let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
      let(:question2) { create(:question, questionnaire: questionnaire, weight: 2, id: 2) }

      let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1, reviewer_id: 1) }
      let(:response_map2) { create(:review_response_map, id: 2, reviewed_object_id: 1, reviewer_id: 2) }

      let!(:response_record) { create(:response, id: 1, response_map: response_map) }
      let!(:response_record2) { create(:response, id: 2, response_map: response_map2) }

      let!(:answer) { create(:answer, question: question1, response_id: 1) }
      let(:assignment) { build(:assignment, id: 1) }

      let(:response1) { double("respons1") }
      let(:response2) { double("respons2") }

      before(:each) do
        @total_score = 50.0
        allow(Answer).to receive(:get_total_score).and_return(50,30)
      end

      it 'scores varying rubrics and returns review scores' do
        allow(ResponseMap).to receive(:where).and_return([response_map, response_map2])
        temp = assignment.compute_reviews_hash()
        expect(temp).to eql({1=>{1=>50}, 2=>{1=>30}})
      end
    end
  end

  describe '#compute_avg_and_ranges_hash' do
    context 'when current assignment varys rubrics by round' do
      it 'computes avg score and score range for each team in each round and return scores' do
        # Write your test here!
        on_the_fly_calc = Assignment.new(id: 1, name: 'Test Assgt')
        #     on_the_fly_calc.extend(OnTheFlyCalc)
        questions= [question2,question3]
        allow(Assignment).to receive(:contributors).and_return(double('AssignmentTeam'))
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(Assignment).to receive(:rounds_of_reviews).and_return(1)
        allow(Assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
        allow(Question).to receive(:where).with(any_args).and_return(questions)
        print on_the_fly_calc.compute_avg_and_ranges_hash
      end
    end
    context 'when current assignment does not vary rubrics by round' do
      it 'computes avg score and score range for each team and return scores' do
        # Write your test here!
      end
    end
  end

  xdescribe '#scores' do
    context 'when current assignment varys rubrics by round' do
      it 'calculates rounds/scores/assessments and return scores' do
        questions = [question1]
        score = {min: 20, max:50, avg:25}
        allow(on_the_fly_calc).to receive(:teams).and_return([team, team])
        allow(on_the_fly_calc).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(on_the_fly_calc).to receive(:num_review_rounds).and_return([])
        allow(on_the_fly_calc).to receive(:calculate_score).and_return(score)
        allow(on_the_fly_calc).to receive(:score_assignment).and_return('')
        allow(on_the_fly_calc).to receive(:total_num_of_assessments).and_return(3)
        allow(on_the_fly_calc).to receive(:index).and_return(0)
        allow(on_the_fly_calc).to receive(:total_score).and_return(90)
        allow(on_the_fly_calc).to receive(:score).and_return(score)
        print on_the_fly_calc.scores(questions)
      end
    end

    context 'when current assignment does not vary rubrics by round' do

      let(:response1) { double("respons1") }
      it 'computes and returns scores' do
        # Write your test here!
        score = {min: 20, max:50, avg:25}
        assessments = nil
        questions= [question1]
        response = :response
        allow(on_the_fly_calc).to receive(:score_assignment).and_return('')
        allow(on_the_fly_calc).to receive(:teams).and_return([team, team])
        allow(on_the_fly_calc).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(on_the_fly_calc).to receive(:index).and_return(0)
        allow(ReviewResponseMap).to receive(:get_assessments_for).with(team).and_return([])
        allow(on_the_fly_calc).to receive(:score).and_return(score)
        allow(Answer).to receive(:compute_scores).with(any_args)
        print on_the_fly_calc.scores(questions)
      end
    end
  end
end
