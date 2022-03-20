describe 'SummaryHelper' do
  let(:answer) { Answer.new(answer: 1, comments: 'This is a sentence. This is another sentence.', question_id: 1) }
  let(:answer) { Answer.new(answer: 1, comments: 'This is a sentence. This is another sentence.', question_id: 1) }
  let(:question) {build(:question, weight:1, type:"Criterion")}
  let(:avg_scores_by_criterion) { {a:2.345} }

  before(:each) do
    @summary = SummaryHelper::Summary.new
  end
  describe '#get_sentences' do
    context 'when the answer is nil' do
      it 'returns a nil object' do
        expect(@summary.get_sentences(nil)).to eq(nil)
      end
    end
    context 'when the comment is two sentences' do
      it 'returns an array of two sentences' do
        sentences = @summary.get_sentences(answer)
        expect(sentences.length).to be(2)
      end
    end
  end

  describe '#calculate_round_score' do
   context 'when criteria not available' do
     it 'returns 0' do
       expect(@summary.calculate_round_score(avg_scores_by_criterion, nil)).to eq(0.to_f)
     end
   end
   context 'when criteria not nil' do
     it 'get 2 round_score  ' do
       expect(@summary.calculate_round_score(avg_scores_by_criterion, question)).to be_within(0.01).of(2.345)
     end
   end
 end

  describe '#calculate_avg_score_by_round'do
   context 'when avg_scores_by_criterion available' do
     it 'gives 2 round value' do
       expect(@summary.calculate_avg_score_by_round(avg_scores_by_criterion, question)).to eq(2.35)
     end
   end
  end

end
