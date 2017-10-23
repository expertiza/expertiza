describe Response do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:answer2) { Answer.new(answer: 2, comments: 'Answer text', question_id: 2) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { TextArea.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:questionnaire2) { ReviewQuestionnaire.new(id: 2, questions: [question2], max_question_score: 5) }

  describe '#response_id' do
    it 'returns the id of current response'
  end

  describe '#display_as_html' do
    context 'when prefix is not nil, which means view_score page in instructor end' do
      it 'returns corresponding html code'
    end

    context 'when prefix is nil, which means view_score page in student end and question type is TextArea' do
      it 'returns corresponding html code'
    end
  end

  describe '#get_total_score' do
    it 'computes the total score of a review'
  end

  describe '#get_average_score' do
    context 'when get_maximum_score returns 0' do
      it 'returns N/A'
    end

    context 'when get_maximum_score does not return 0' do
      it 'calculates the maximum score'
    end
  end

  describe '#get_maximum_score' do
    it 'returns the maximum possible score for current response'
  end

  describe '#email' do
    it 'calls email method in corresponding respons maps'
  end

  describe '#questionnaire_by_answer' do
    context 'when answer is not nil' do
      it 'returns the questionnaire of the question of current answer'
    end

    context 'when answer is nil' do
      it 'returns review questionnaire of current assignment'
    end
  end

  describe '.concatenate_all_review_comments' do
    it 'returns concatenated review comments and # of reviews in each round'
  end

  describe '.get_volume_of_review_comments' do
    it 'returns volumes of review comments in each round'
  end

  describe '#significant_difference?' do
    context 'when count is 0' do
      it 'returns false'
    end

    context 'when count is not 0' do
      context 'when the difference between average score on same artifact from others and current score is bigger thatn allowed percentage' do
        it 'returns true'
      end
    end
  end

  describe '.avg_scores_and_count_for_prev_reviews' do
    context 'when current response is not in current response array' do
      it 'returns the average score and count of previous reviews'
    end
  end
end
