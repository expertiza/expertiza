describe Response do
  let(:participant2) { build(:participant, id: 2) }
  let(:user) { User.new(id: 1, role: build(:role_of_student), name: 'no name', fullname: 'no one')}
  let(:participant1) {Participant.new(id: 2, user: user)}
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:participant) { build(:participant, id: 1, parent_id: 1, assignment: assignment, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map1) { build(:review_response_map, id: 2, assignment: assignment, reviewer: participant1, reviewee: team) }
  let(:answer5) { build(:answer, id:1, question_id: 5, answer: 5) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer5]) }
  let(:response1) { build(:response, id: 2, map_id: 2, response_map: review_response_map1, scores: [answer2]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:answer2) { Answer.new(answer: 2, comments: 'Answer text', question_id: 2) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { TextArea.new(id: 1, weight: 2, break_before: true) }
  let(:question3) { ScoredQuestion.new(id: 5, weight: 2, questionnaire: questionnaire1) }
  let(:question4) { ScoredQuestion.new(id: 3, weight: 0, questionnaire: questionnaire1) }
  let(:questionnaire1) { build(:questionnaire) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:questionnaire2) { ReviewQuestionnaire.new(id: 2, questions: [question2], max_question_score: 5) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, notification_limit: 50) }

  describe '#response_id' do
    it 'returns the id of current response' do
      expect(response.response_id).to eq 1
    end
  end

  describe '#display_as_html' do
    context 'when prefix is not nil, which means view_score page in instructor end' do
      it 'returns corresponding html code' do
        output = "<h4><B>Review </B></h4><B>Reviewer: </B>no one (no name)&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_instructor_2Link\" onClick=\"toggleElement('review_instructor_2','review');return false;\">show review</a><BR/><table id=\"review_instructor_2\" style=\"display: none;\" class=\"table table-bordered\"><tr><td><b>Additional Comment: </b></td></tr></table>"
        expect(response1.display_as_html('instructor')).to eq output
      end
    end

    context 'when prefix is nil, which means view_score page in student end and question type is TextArea' do
      it 'returns corresponding html code' do
        output = "<table width=\"100%\"><tr><td align=\"left\" width=\"70%\"><b>Review </b>&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_1Link\" onClick=\"toggleElement('review_1','review');return false;\">show review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\" style=\"display: none;\" class=\"table table-bordered\"><tr><td><b>Additional Comment: </b></td></tr></table>"
        expect(response.display_as_html).to eq output
      end
    end
  end

  describe '#total_score' do
    it 'computes the total score of a review' do
      allow(Question).to receive(:find).and_return(question3)
      expect(response.total_score).to eq 10
    end
  end

  describe '#average_score' do
    context 'when maximum_score returns 0' do
      it 'returns N/A' do
        allow(Question).to receive(:find).and_return(question4)
        expect(response.average_score).to eq 'N/A'
      end
    end

    context 'when maximum_score does not return 0' do
      it 'calculates the maximum score' do
        allow(Question).to receive(:find).and_return(question3)
        expect(response.average_score).to eq 100
      end
    end
  end

  describe '#maximum_score' do
    it 'returns the maximum possible score for current response' do
      allow(Question).to receive(:find).and_return(question3)
      expect(response.maximum_score).to eq 10
    end
  end

  describe '#email' do
    it 'calls email method in corresponding response maps' do
      expect(response).to receive(:email)
      response.email
    end
  end

  describe '#questionnaire_by_answer' do
    context 'when answer is not nil' do
      it 'returns the questionnaire of the question of current answer' do
        allow(Question).to receive(:find).and_return(question3)
        expect(response.questionnaire_by_answer(answer)).to eql(questionnaire1)
      end
    end

    context 'when answer is nil' do
      it 'returns review questionnaire of current assignment' do
        allow(ResponseMap).to receive(:find).and_return(review_response_map)
        allow(Participant).to receive(:find).and_return(participant)
        allow(Questionnaire).to receive(:find).and_return(questionnaire2)
        expect(response.questionnaire_by_answer(nil)).to eq(questionnaire2)
      end
    end
  end

  describe '.concatenate_all_review_comments' do
    it 'returns concatenated review comments and # of reviews in each round' do
      # As this method is getting called from get_volume_of_review_comments
      # we need not test this method separately. Also this method has not been called
      # from any other places.
    end
  end

  describe '.get_volume_of_review_comments' do
    it 'returns volumes of review comments in each round' do
      question_ids = [1, 5]
      result_array = [0, 0, 0, 0]
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(Question).to receive(:get_all_questions_with_comments_available).and_return(question_ids)
      allow(ReviewResponseMap).to receive_message_chain(:where, :find_each).and_return(review_response_map)
      expect(Response.get_volume_of_review_comments(1,1)).to eq result_array
    end
  end

  describe '#significant_difference?' do
    context 'when count is 0' do
      it 'returns false' do
        existingResponse = [response]
        allow(Response).to receive(:get_assessments_for).and_return(existingResponse)
        allow(Response).to receive(:avg_scores_and_count_for_prev_reviews).and_return([0,0])
        expect(response.significant_difference?).to eq false
      end
    end

    context 'when count is not 0' do
      context 'when the difference between average score on same artifact from others and current score is bigger thatn allowed percentage' do
        it 'returns true' do
          existingResponse = [response]
          allow(Response).to receive(:get_assessments_for).and_return(existingResponse)
          allow(Response).to receive(:avg_scores_and_count_for_prev_reviews).and_return([2.0,1])
          allow(Question).to receive(:find).and_return(question3)
          allow(AssignmentQuestionnaire).to receive(:find_by).and_return(assignment_questionnaire)
          expect(response.significant_difference?).to eq true
        end
      end
    end
  end

  describe '.avg_scores_and_count_for_prev_reviews' do
    context 'when current response is not in current response array' do
      it 'returns the average score and count of previous reviews' do
        existing_response = [response]
        result_array = [1.0, 1]
        allow(Question).to receive(:find).and_return(question3)
        expect(Response.avg_scores_and_count_for_prev_reviews(existing_response, response1)).to eq result_array
      end
    end
  end
end
