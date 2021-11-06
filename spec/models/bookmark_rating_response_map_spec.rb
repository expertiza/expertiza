describe BookmarkRatingResponseMap do
  describe '#reviewee' do
    let(:model) { BookmarkRatingResponseMap.new }

    # check if class belongs to reviewee
    it { should belong_to :reviewee }

    # check if class belongs to assignment
    it { should belong_to :assignment }
    
    it '#contributor' do
      expect(model.contributor).to be(nil)
    end

    it '#get_title' do
      expect(model.get_title).to eq("Bookmark Review")
    end
  end
end
