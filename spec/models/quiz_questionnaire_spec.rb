describe QuizQuestionnaire do
  let(:quiz_questionnaire) { QuizQuestionnaire.new }
  let(:quiz_response_map) { build(:quiz_response_map) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1) }
  describe '#symbol' do
    it 'returns the quiz symbol' do
      expect(quiz_questionnaire.symbol).to eq('quiz'.to_sym)
    end
  end
  describe '#get_assessments_for' do
    it 'returns the responses associated with the participant' do
      allow(QuizResponseMap).to receive(:assessments_for).with(participant).and_return([response])
      expect(quiz_questionnaire.get_assessments_for(participant)).to eq([response])
    end
  end
  describe '#get_weighted_score' do
    context 'when there is no average available' do
      it 'returns 0' do
        scores = { quiz: { scores: { avg: nil } } }
        expect(quiz_questionnaire.get_weighted_score(scores)).to eq(0)
      end
    end
    context 'when there is an average available' do
      it 'returns the average' do
        scores = { quiz: { scores: { avg: 96 } } }
        expect(quiz_questionnaire.get_weighted_score(scores)).to eq(96)
      end
    end
  end
  describe '#taken_by_anyone?' do
    context 'when the quiz has not been taken' do
      it 'returns false' do
        allow(ResponseMap).to receive(:where).and_return([])
        expect(quiz_questionnaire.taken_by_anyone?).to be_falsey
      end
    end
    context 'when the quiz has been taken' do
      it 'returns false' do
        allow(ResponseMap).to receive(:where).and_return([QuizResponseMap.new])
        expect(quiz_questionnaire.taken_by_anyone?).to be_truthy
      end
    end
  end
  describe '#taken_by?' do
    context 'when the quiz has not been taken' do
      it 'returns false' do
        allow(ResponseMap).to receive(:where).and_return([])
        expect(quiz_questionnaire.taken_by?(participant)).to be_falsey
      end
    end
    context 'when the quiz has been taken' do
      it 'returns false' do
        allow(ResponseMap).to receive(:where).and_return([QuizResponseMap.new])
        expect(quiz_questionnaire.taken_by?(participant)).to be_truthy
      end
    end
  end
end
