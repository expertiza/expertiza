describe BookmarkRatingResponseMap do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:itemnaire1) { build(:itemnaire, id: 1, type: 'MetareviewQuestionnaire') }
  let(:itemnaire2) { build(:itemnaire, id: 2, type: 'BookmarkRatingQuestionnaire') }
  let(:model) { BookmarkRatingResponseMap.new }
  describe '#reviewee' do
    # check if class belongs to reviewee
    it { should belong_to :reviewee }

    # check if class belongs to assignment
    it { should belong_to :assignment }

    it '#contributor' do
      expect(model.contributor).to be(nil)
    end

    it '#get_title' do
      expect(model.get_title).to eq('Bookmark Review')
    end
  end
  describe '#itemnaire' do
    it 'returns bookmark rating itemnaires associated with the assignment' do
      model.assignment = assignment
      itemnaires = [itemnaire1, itemnaire2]
      allow(assignment).to receive(:itemnaires).and_return(itemnaires)
      allow(itemnaires).to receive(:find_by).with(type: 'BookmarkRatingQuestionnaire').and_return(itemnaire2)
      expect(model.itemnaire).to eq(itemnaire2)
    end
  end
  describe '#bookmark_response_report' do
    it 'returns the matching map' do
      out = [model]
      allow(BookmarkRatingResponseMap).to receive(:select).with('DISTINCT reviewer_id').and_return(out)
      allow(out).to receive(:where).with('reviewed_object_id = ?', 1).and_return(out)
      expect(BookmarkRatingResponseMap.bookmark_response_report(1)).to eq([model])
    end
  end
end
