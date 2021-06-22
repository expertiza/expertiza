describe BookmarkRatingQuestionnaire do
  let(:questionnaire) { build(:questionnaire, id: 2, type: 'BookmarkRatingQuestionnaire') }
  let(:participant) { build(:participant, id: 1) }
  describe '#symbol' do
    it 'returns the symbol for a Bookmark Rating Questionnaire' do
      expect(questionnaire.symbol).to eq(:bookmark)
    end
  end
  describe '#get_assessments_for' do
    it 'returns the assessments for a given participant' do
      allow(participant).to receive(:bookmark_review).and_return([questionnaire])
      expect(questionnaire.get_assessments_for(participant)).to eq([questionnaire])
    end
  end
end