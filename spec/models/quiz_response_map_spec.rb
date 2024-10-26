describe QuizResponseMap do
  let(:quiz_itemnaire) { QuizQuestionnaire.new }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:quiz_response_map) { build(:quiz_response_map, quiz_itemnaire: quiz_itemnaire, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:response) { build(:response, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:score) { double }
  describe '#itemnaire' do
    it 'returns the itemnaire' do
      expect(quiz_response_map.itemnaire).to eq(quiz_itemnaire)
    end
  end
  describe '#get_title' do
    it 'returns the name of responses it holds' do
      expect(quiz_response_map.get_title).to eq('Quiz')
    end
  end
  describe '#delete' do
    it 'deletes the map and associated responses' do
      expect(quiz_response_map.delete).to eq(quiz_response_map)
    end
  end
  describe '#mapping_for_reviewer' do
    it 'returns quiz response maps where the reviewer is the participant' do
      allow(QuizResponseMap).to receive(:where).and_return([quiz_response_map])
      expect(QuizResponseMap.mappings_for_reviewer(participant.id)).to eq([quiz_response_map])
    end
  end
  describe '#quiz_score' do
    context 'when the quiz has not been taken' do
      it 'returns N/A' do
        allow(quiz_response_map).to receive(:response).and_return(nil)
        expect(quiz_response_map.quiz_score).to eq('N/A')
      end
    end
    context 'when the score has not been calculated' do
      it 'returns N/A' do
        allow(quiz_response_map).to receive(:response).and_return([response])
        allow(ScoreView).to receive(:find_by_sql).and_return(nil)
        expect(quiz_response_map.quiz_score).to eq('N/A')
      end
    end
    context 'when the score has been calculated' do
      it 'returns the score rounded' do
        allow(quiz_response_map).to receive(:response).and_return([response])
        calculated_score = double('Calculated Score')
        calculated_scores = [calculated_score]
        allow(ScoreView).to receive(:find_by_sql).and_return(calculated_scores)
        allow(calculated_score).to receive(:graded_percent).and_return(97)
        expect(quiz_response_map.quiz_score).to eq(97)
      end
    end
  end
end
