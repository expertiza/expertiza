describe "SummaryHelper" do
	let(:answer) { Answer.new(answer: 1, comments: 'This is a sentence. This is anohter sentence.', question_id: 1) }
	describe '#get_sentences' do
  	context 'when the answer is nil' do
      it 'returns a nil object' do
        expect(get_sentences(nil)).to eq(nil)
      end
    end
    context 'when the comment is two sentences' do
      it 'returns an array of two sentences' do
        sentences = get_sentences(answer)
        expect(sentences.length).to be(2)
      end
    end
  end
end