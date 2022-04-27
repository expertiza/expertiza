# require for webservice calls
require 'json'
require 'rest_client'

describe 'SummaryHelper' do
  let(:answer) { Answer.new(answer: 1, comments: 'This is a sentence. This is another sentence.', question_id: 1) }
  let(:answer1){ Answer.new(answer: 2, comments: 'This is a sentence1. This is another sentence1.', question_id: 2)}
  let(:question) {build(:question, weight:1, type:"Criterion")}
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

  describe 'get_max_score_for_question' do
    context 'When question type is Checkbox' do
      let(:questionOne){Question.new(type:'Checkbox')}
      it 'returns 1' do
        max_score = @summary.get_max_score_for_question(questionOne)
        expect(max_score).to be(1)
      end
    end
    context 'When question type is not Checkbox' do
      let(:questionnaire1) { build(:questionnaire, id: 2) }
      let(:questionTwo) { build(:question, questionnaire: questionnaire1, weight: 1, id: 1) }
      it 'return the max score for the provided question' do
        allow(Questionnaire).to receive(:where).with(id:2).and_return(questionnaire1)
        allow(questionnaire1).to receive(:first).and_return(questionnaire1)
        expect(@summary.get_max_score_for_question(questionTwo)).to eql(5)
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
    context 'when the question_answers is not nil' do
      it 'add the comment to an array to be converted as a json request' do
        comments = @summary.break_up_comments_to_sentences([answer])
        expect(comments.length).to be(2)
      end
    end
    context 'when the question_answers is nil' do
      it 'returns an empty array' do
        comments = @summary.break_up_comments_to_sentences([])
        expect(comments.length).to be(0)
      end
    end
  end

  describe '#calculate_avg_score_by_criterion' do
    context 'when question_answers are available' do
      it 'calculate percentage question_score  & no float' do
        expect(@summary.calculate_avg_score_by_criterion([answer,answer1], 3)).to be_within(0).of(50)
        end
    end
    context 'when question_answers are not available' do
      it 'gives question scores 0.0' do
        expect(@summary.calculate_avg_score_by_criterion([], 3)).to eq(0.0)
      end
    end

    context 'when q_max_score = 0' do
      it 'gives pure question_score' do
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
