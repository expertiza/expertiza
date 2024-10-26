# require for webservice calls
require 'json'
require 'rest_client'

describe 'SummaryHelper' do
  let(:answer) { Answer.new(answer: 1, comments: 'This is a sentence. This is another sentence.', item_id: 1) }
  let(:answer1){ Answer.new(answer: 2, comments: 'This is a sentence1. This is another sentence1.', item_id: 2)}
  let(:item) {build(:item, weight:1, type:"Criterion")}
  let(:avg_scores_by_criterion) { {a:2.345} }

  before(:each) do
    @summary = SummaryHelper::Summary.new
    stub_const('WEBSERVICE_CONFIG', 'summary_webservice_url' => 'expertiza.ncsu.edu')
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

  describe 'get_max_score_for_item' do
    context 'When item type is Checkbox' do
      let(:itemOne){Question.new(type:'Checkbox')}
      it 'returns 1' do
        max_score = @summary.get_max_score_for_item(itemOne)
        expect(max_score).to be(1)
      end
    end
    context 'When item type is not Checkbox' do
      let(:itemnaire1) { build(:itemnaire, id: 2) }
      let(:itemTwo) { build(:item, itemnaire: itemnaire1, weight: 1, id: 1) }
      it 'return the max score for the provided item' do
        allow(Questionnaire).to receive(:where).with(id:2).and_return(itemnaire1)
        allow(itemnaire1).to receive(:first).and_return(itemnaire1)
        expect(@summary.get_max_score_for_item(itemTwo)).to eql(5)
      end
    end
  end

  describe '#summarize_sentence' do
    context 'successful webservice call' do
      comments = ["Hello this is first comment", "This is second comment"]
      summary_ws_url = WEBSERVICE_CONFIG['summary_webservice_url']
      it 'return success' do
        expect(@summary.summarize_sentences(comments,summary_ws_url)).not_to eql(nil)
      end
    end
  end

  describe '#break_up_comments_to_sentences' do
    context 'when the item_answers is not nil' do
      it 'add the comment to an array to be converted as a json request' do
        comments = @summary.break_up_comments_to_sentences([answer])
        expect(comments.length).to be(2)
      end
    end
    context 'when the item_answers is nil' do
      it 'returns an empty array' do
        comments = @summary.break_up_comments_to_sentences([])
        expect(comments.length).to be(0)
      end
    end
  end

  describe '#calculate_avg_score_by_criterion' do
    context 'when item_answers are available' do
      it 'calculate percentage item_score  & no float' do
        expect(@summary.calculate_avg_score_by_criterion([answer,answer1], 3)).to be_within(0).of(50)
        end
    end
    context 'when item_answers are not available' do
      it 'gives item scores 0.0' do
        expect(@summary.calculate_avg_score_by_criterion([], 3)).to eq(0.0)
      end
    end

    context 'when q_max_score = 0' do
      it 'gives pure item_score' do
        expect(@summary.calculate_avg_score_by_criterion([answer,answer1], 0)).to eq(3.0)
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
       expect(@summary.calculate_round_score(avg_scores_by_criterion, item)).to be_within(0.01).of(2.345)
     end
   end
 end

  describe '#calculate_avg_score_by_round'do
   context 'when avg_scores_by_criterion available' do
     it 'gives 2 round value' do
       expect(@summary.calculate_avg_score_by_round(avg_scores_by_criterion, item)).to eq(2.35)
     end
   end
  end

end
