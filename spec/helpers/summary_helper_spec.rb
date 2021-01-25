describe "SummaryHelper" do
	describe '#get_sentences' do
  	context 'when the answer is nil' do
      it 'returns a nil object' do
        expect(SummaryHelper.get_sentences(nil)).to eq(nil)
      end
    end
    context 'when the comment is two sentences' do
      it 'returns an array of two sentences' do
        allow(answer). to receive(:comments).and_return("This is a sentence. This is anohter sentence.")
        sentences = SummaryHelper.get_sentences(answer)
        expect(sentences.length).to be(2)
      end
    end
  end
end