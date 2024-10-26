describe BookmarkRatingQuestionnaire do
  let(:itemnaire) { build(:bookmark_itemnaire, id: 2) }
  let(:participant) { build(:participant, id: 1) }
  describe '#symbol' do
    it 'returns the symbol for a Bookmark Rating Questionnaire' do
      expect(itemnaire.symbol).to eq(:bookmark)
    end
  end
  describe '#get_assessments_for' do
    it 'returns the assessments for a given participant' do
      allow(participant).to receive(:bookmark_reviews).and_return([itemnaire])
      expect(itemnaire.get_assessments_for(participant)).to eq([itemnaire])
    end
  end
end
