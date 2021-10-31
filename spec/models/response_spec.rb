describe Response do
  let(:participant) { build(:participant, id: 1, parent_id:1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:team) { build(:assignment_team) }
  let(:signed_up_team) { build(:signed_up_team, team_id: team.id) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:answer2) { Answer.new(answer: 2, comments: 'Answer text', question_id: 2) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire1) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire1, weight: 1, id: 1) }
  let(:question2) { TextArea.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:questionnaire2) { ReviewQuestionnaire.new(id: 2, questions: [question2], max_question_score: 5) }
  let(:tag_prompt) {TagPrompt.new(id: 1, prompt: "prompt")}
  let(:tag_prompt_deployment) {TagPromptDeployment.new(id: 1, tag_prompt_id: 1, assignment_id: 1, questionnaire_id: 1, question_type: 'Criterion')}
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, map_id: 1, response_map: response_map) }
  before(:each) do
    allow(response).to receive(:map).and_return(review_response_map)
  end

  describe '#response_id' do
    it 'returns the id of current response' do
      expect(response.response_id).to eq(1)
    end
  end

  describe '#display_as_html' do
    before(:each) do
      allow(Answer).to receive(:where).with(response_id: 1).and_return([answer])
    end

    context 'when prefix is not nil, which means view_score page in instructor end' do
      it 'returns corresponding html code' do
        allow(response).to receive(:questionnaire_by_answer).with(answer).and_return(questionnaire)
        allow(questionnaire).to receive(:max_question_score).and_return(5)
        allow(questionnaire).to receive(:id).and_return(1)
        allow(assignment).to receive(:id).and_return(1)
        allow(question).to receive(:view_completed_question).with(1, answer, 5, nil, nil).and_return('Question HTML code')
        expect(response.display_as_html('Instructor end', 0)).to eq("<h4><B>Review 0</B></h4><B>Reviewer: </B>no one (no name)&nbsp;&nbsp;&nbsp;"\
          "<a href=\"#\" name= \"review_Instructor end_1Link\" onClick=\"toggleElement('review_Instructor end_1','review');return false;\">"\
          "hide review</a><BR/><table id=\"review_Instructor end_1\" class=\"table table-bordered\">"\
          "<tr class=\"warning\"><td>Question HTML code</td></tr><tr><td><b>Additional Comment: </b></td></tr></table>")
      end
    end

    context 'when prefix is nil, which means view_score page in student end and question type is TextArea' do
      it 'returns corresponding html code' do
        allow(response).to receive(:questionnaire_by_answer).with(answer).and_return(questionnaire2)
        allow(questionnaire2).to receive(:max_question_score).and_return(5)
        allow(question2).to receive(:view_completed_question).with(1, answer).and_return('Question HTML code')
        expect(response.display_as_html(nil, 0)).to eq("<table width=\"100%\"><tr><td align=\"left\" width=\"70%\"><b>Review 0</b>"\
          "&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_1Link\" onClick=\"toggleElement('review_1','review');return false;\">"\
          "hide review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\""\
          " class=\"table table-bordered\"><tr class=\"warning\"><td>Question HTML code</td></tr><tr><td><b>"\
          "Additional Comment: </b></td></tr></table>")
      end
    end
  end

  describe '#aggregate_questionnaire_score' do
    it 'computes the total score of a review' do
      question2 = double('ScoredQuestion', weight: 2)
      allow(Question).to receive(:find).with(1).and_return(question2)
      allow(question2).to receive(:is_a?).with(ScoredQuestion).and_return(true)
      allow(question2).to receive(:answer).and_return(answer)
      expect(response.aggregate_questionnaire_score).to eq(2)
    end
  end

  describe '#average_score' do
    context 'when maximum_score returns 0' do
      it 'returns N/A' do
        allow(response).to receive(:maximum_score).and_return(0)
        expect(response.average_score).to eq('N/A')
      end
    end

    context 'when maximum_score does not return 0' do
      it 'calculates the maximum score' do
        allow(response).to receive(:aggregate_questionnaire_score).and_return(4)
        allow(response).to receive(:maximum_score).and_return(5)
        expect(response.average_score).to eq(80)
      end
    end
  end

  describe '#maximum_score' do
    it 'returns the maximum possible score for current response' do
      question2 = double('ScoredQuestion', weight: 2)
      allow(Question).to receive(:find).with(1).and_return(question2)
      allow(question2).to receive(:is_a?).with(ScoredQuestion).and_return(true)
      allow(response).to receive(:questionnaire_by_answer).with(answer).and_return(questionnaire)
      allow(questionnaire).to receive(:max_question_score).and_return(5)
      expect(response.maximum_score).to eq(10)
    end

    it 'returns the maximum possible score for current responsesssss' do
      response.scores = []
      question2 = double('ScoredQuestion', weight: 2)
      allow(Question).to receive(:find).with(1).and_return(question2)
      allow(question2).to receive(:is_a?).with(ScoredQuestion).and_return(true)
      allow(response).to receive(:questionnaire_by_answer).with(nil).and_return(questionnaire)
      allow(questionnaire).to receive(:max_question_score).and_return(5)
      expect(response.maximum_score).to eq(0)
    end
  end

  describe '#email' do
    it 'calls email method in assignment survey respond map' do
      assignment_survey_response_map = double('AssignmentSurveyResponseMap', reviewer_id: 1)
      allow(ResponseMap).to receive(:find).with(1).and_return(assignment_survey_response_map)
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(assignment_survey_response_map).to receive(:survey?).and_return(true)
      allow(assignment_survey_response_map).to receive(:survey_parent).and_return(assignment)
      allow(assignment_survey_response_map).to receive(:email).with({body: {partial_name: "new_submission"},
                                                                     subject: "A new submission is available for Test Assgt"},
                                                                    participant, assignment).and_return(true)
      expect(response.email).to eq(true)
    end

    it 'calls email method in course survey respond map' do
      course_survey_response_map = double('CourseSurveyResponseMap', reviewer_id: 1)
      allow(ResponseMap).to receive(:find).with(1).and_return(course_survey_response_map)
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(course_survey_response_map).to receive(:survey?).and_return(false)
      allow(course_survey_response_map).to receive(:email).with({body: {partial_name: "new_submission"},
                                                                     subject: "A new submission is available for Test Assgt"},
                                                                    participant, assignment).and_return(true)
      expect(response.email).to eq(true)
    end
  end

  describe '#questionnaire_by_answer' do
    before(:each) do
      allow(SignedUpTeam).to receive(:find_by).with(team_id: team.id).and_return(signed_up_team)
    end
    context 'when answer is not nil' do
      it 'returns the questionnaire of the question of current answer' do
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(question).to receive(:questionnaire).and_return(questionnaire2)
        expect(response.questionnaire_by_answer(answer)).to eq(questionnaire2)
      end
    end
    context 'when answer is nil' do
      it 'returns review questionnaire of current assignment from map itself' do
        allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
        allow(Participant).to receive(:find).with(1).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:review_questionnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire2)
        expect(response.questionnaire_by_answer(nil)).to eq(questionnaire2)
      end
      it 'returns review questionnaire of current assignment from participant' do
        assignment_survey_response_map = double('AssignmentSurveyResponseMap', reviewer_id: 1, reviewee_id:team.id)
        allow(ResponseMap).to receive(:find).with(1).and_return(assignment_survey_response_map)
        allow(Participant).to receive(:find).with(1).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:review_questionnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire2)
        expect(response.questionnaire_by_answer(nil)).to eq(questionnaire2)
      end
    end
  end

  describe '#populate_new_response' do
    context 'when current round response is found' do
      it 'returns the current round response' do
        allow(response).to receive(:populate_new_response).with(:review_response_map, "0").and_return(response)
        expect(response.id).to eq(1)
      end
    end
    context 'when current round response is found' do
      it 'returns a new response object' do
        allow(response).to receive(:populate_new_response).with(:review_response_map, nil).and_return(:new_response)
      end
    end
  end

  describe '.concatenate_all_review_comments' do
    it 'returns concatenated review comments and # of reviews in each round' do
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(assignment).to receive(:num_review_rounds).and_return(2)
      allow(Question).to receive(:get_all_questions_with_comments_available).with(1).and_return([1, 2])
      allow(ReviewResponseMap).to receive_message_chain(:where, :find_each).with(reviewed_object_id: 1, reviewer_id: 1)
        .with(no_args).and_yield(review_response_map)
      response1 = double('Response', round: 1, additional_comment: '')
      response2 = double('Response', round: 2, additional_comment: 'LGTM')
      allow(review_response_map).to receive(:response).and_return([response1, response2])
      allow(response1).to receive(:scores).and_return([answer])
      allow(response2).to receive(:scores).and_return([answer2])
      expect(Response.concatenate_all_review_comments(1, 1)).to eq(["Answer textAnswer textLGTM", 2, [nil, "Answer text", "Answer textLGTM", ""], [nil, 1, 1, 0]])
    end
  end

  describe '.volume_of_review_comments' do
    it 'returns volumes of review comments in each round' do
      allow(Response).to receive(:concatenate_all_review_comments).with(1, 1)
                                                                  .and_return(["Answer textAnswer textLGTM", 2, [nil, "Answer text", "Answer textLGTM", ""], [nil, 1, 1, 0]])
      expect(Response.volume_of_review_comments(1, 1)).to eq([1, 2, 2, 0])
    end
  end

  describe '#significant_difference?' do
    before(:each) do
      allow(ReviewResponseMap).to receive(:assessments_for).with(team).and_return([response])
    end

    context 'when count is 0' do
      it 'returns false' do
        allow(Response).to receive(:avg_scores_and_count_for_prev_reviews).with([response], response).and_return([0, 0])
        expect(response.significant_difference?).to be false
      end
    end

    context 'when count is not 0' do
      context 'when the difference between average score on same artifact from others and current score is bigger thatn allowed percentage' do
        it 'returns true' do
          allow(Response).to receive(:avg_scores_and_count_for_prev_reviews).with([response], response).and_return([0.8, 2])
          allow(response).to receive(:aggregate_questionnaire_score).and_return(93)
          allow(response).to receive(:maximum_score).and_return(100)
          allow(response).to receive(:questionnaire_by_answer).with(answer).and_return(questionnaire)
          allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                             .and_return(double('AssignmentQuestionnaire', notification_limit: 5.0))
          expect(response.significant_difference?).to be true
        end
      end
    end
  end

  describe '.avg_scores_and_count_for_prev_reviews' do
    context 'when current response is not in current response array' do
      it 'returns the average score and count of previous reviews' do
        allow(response).to receive(:aggregate_questionnaire_score).and_return(96)
        allow(response).to receive(:maximum_score).and_return(100)
        expect(Response.avg_scores_and_count_for_prev_reviews([response], double('Response', id: 6))).to eq([0.96, 1])
      end
    end
  end

  describe "#test compute scores" do
    let(:response1) { double("respons1") }
    let(:response2) { double("respons2") }

    before(:each) do
      @total_score = 100.0
      allow(Response).to receive(:assessment_score).and_return(@total_score)
    end

    it "returns nil if list of assessments is empty" do
      assessments = []
      scores = Response.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq nil
      expect(scores[:min]).to eq nil
      expect(scores[:avg]).to eq nil
    end

    it "returns scores when a single valid assessment of total score 100 is give" do
      assessments = [response1]
      Response.instance_variable_set(:@invalid, 0)
      scores = Response.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq @total_score
    end

    it "returns scores when two valid assessments of total scores 80 and 100 are given" do
      assessments = [response1, response2]
      Response.instance_variable_set(:@invalid, 0)
      total_score1 = 100.0
      total_score2 = 80.0
      allow(Response).to receive(:assessment_score).and_return(total_score1, total_score2)
      scores = Response.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq total_score1
      expect(scores[:min]).to eq total_score2
      expect(scores[:avg]).to eq (total_score1 + total_score2) / 2
    end

    it "returns scores when an invalid assessments is given" do
      assessments = [response1]
      Response.instance_variable_set(:@invalid, 1)
      scores = Response.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq 0
    end

    it "returns scores when invalid flag is nil" do
      assessments = [response1]
      Response.instance_variable_set(:@invalid, nil)
      scores = Response.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq @total_score
    end

    it "checks if assessment_score function is called" do
      assessments = [response1]
      expect(Response).to receive(:assessment_score).with(response: assessments, questions: [question1]).and_return(@total_score)
      scores = Response.compute_scores(assessments, [question1])
    end
  end

  describe "#test get total score" do
    it "returns total score when required conditions are met" do
      # stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
      allow(ScoreView).to receive(:questionnaire_data).and_return(double("scoreview", weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4))
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: "1")])
      expect(Response.assessment_score(response: [response_record], questions: [question1])).to eq 100.0
      # output calculation is (weighted_score / (sum_of_weights * max_question_score)) * 100
      # 4.0
    end

    it "returns total score when one answer is nil for scored question and its weight gets removed from sum_of_weights" do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double("scoreview", weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4))
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Response.assessment_score(response: [response_record], questions: [question1])).to be_within(0.01).of(125.0)
    end

    it "returns -1 when answer is nil for scored question which makes sum of weights = 0" do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double("scoreview", weighted_score: 20, sum_of_weights: 1, q1_max_question_score: 5))
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Response.assessment_score(response: [response_record], questions: [question1])).to eq -1.0
    end

    it "returns -1 when weighted_score of questionnaireData is nil" do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double("scoreview", weighted_score: nil, sum_of_weights: 5, q1_max_question_score: 5))
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Response.assessment_score(response: [response_record], questions: [question1])).to eq -1.0
    end

    xit "checks if submission_valid? is called" do
      allow(ScoreView).to receive(:questionnaire_data).and_return(double("scoreview", weighted_score: nil, sum_of_weights: 5, q1_max_question_score: 5))
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Answer).to receive(:submission_valid?)
      Response.assessment_score(response: [response_record], questions: [question1])
    end
  end
end
