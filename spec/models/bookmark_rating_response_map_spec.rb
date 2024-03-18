describe BookmarkRatingResponseMap do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'MetareviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'BookmarkRatingQuestionnaire') }
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
  describe '#questionnaire' do
    it 'returns bookmark rating questionnaires associated with the assignment' do
      model.assignment = assignment
      questionnaires = [questionnaire1, questionnaire2]
      allow(assignment).to receive(:questionnaires).and_return(questionnaires)
      allow(questionnaires).to receive(:find_by).with(type: 'BookmarkRatingQuestionnaire').and_return(questionnaire2)
      expect(model.questionnaire).to eq(questionnaire2)
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
