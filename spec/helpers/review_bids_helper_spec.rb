describe ReviewBidsHelper do
  let(:topic) { build(:topic) }
  describe '#get_intelligent_topic_row_review_bids' do
    context 'when no selected topics' do
      it 'returns a row' do
        allow(ReviewBid).to receive(:where).and_return([])
        expect(helper.get_intelligent_topic_row_review_bids(topic, nil, 2)).to eq("<tr id=\"topic_\" style=\"background-color:rgb(47,352,0)\">")
      end
    end
  end
  describe '#get_topic_bg_color_review_bids' do
    context 'when bid size is 0' do
      it 'changes colour' do
        allow(ReviewBid).to receive(:where).and_return([])
        num_bids=0
        expect(helper.get_topic_bg_color_review_bids(topic,2)).to eq("rgb(47,352,0)")
      end
    end
  end
end