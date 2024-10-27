describe ReviewQuestionnaire do
  let(:participant) { build(:participant, id: 1, reviews: [response_map]) }
  let(:questionnaire) { build(:questionnaire, id: 1) }
  let(:response_map) { build(:review_response_map, id: 1) }
  let(:response) { build(:response, is_submitted: true) }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  describe '#get_assessments_for' do
    it 'returns the response map associated with the participant' do
      allow(ReviewResponseMap).to receive(:assessments_for).and_return([response])
      expect(questionnaire.get_assessments_for(participant)).to eq([response])
    end
  end
  describe '#get_assessments_round_for' do
    context 'when the team is not found' do
      it 'returns nil' do
        allow(AssignmentTeam).to receive(:team).and_return(nil)
        expect(questionnaire.get_assessments_round_for(participant, 1)).to be_nil
      end
    end
    context 'when the responses are submitted in round 1' do
      it 'returns the response' do
        allow(AssignmentTeam).to receive(:team).and_return(team)
        allow(ResponseMap).to receive(:where).and_return([response_map])
        allow(response_map).to receive(:response).and_return([response])
        expect(questionnaire.get_assessments_round_for(participant, 1)).to eq([response])
      end
    end
  end
end
