class ResponseAnalyticTestDummyClass 
	attr_accessor :scores
	require 'analytic/response_analytic'
	include ResponseAnalytic
	
	def initialize(scores)
		@scores = scores
	end
end

describe ResponseAnalytic do
	let(:questionnaire) { create(:questionnaire, id: 1) }
	let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
	let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
	let!(:answer1) { create(:answer, question: question1, response_id: 1, id: 1) }
	let!(:answer2) { create(:answer, question: question1, response_id: 1, id: 2) }
  let!(:answer3) { create(:answer, question: question1, response_id: 1, id: 3) }
  before(:each) do
    @scores = [answer1, answer2, answer3]
  end

  describe '#word_count_list' do
    context 'there are no answers associated with the response' do
      it 'will return [0]' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.word_count_list).to eq([0])
      end
    end
    context 'there are three answers associated with the response, with word counts of 50, 75, and 100' do
      it 'will return [50, 75, 100]' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:word_count).and_return(50)
        allow(answer2).to receive(:word_count).and_return(75)
        allow(answer3).to receive(:word_count).and_return(100)
        expect(dc.word_count_list).to eq([50, 75, 100])
      end
    end
  end
  describe '#character_count_list' do

  end
  describe '#question_score_list' do

  end
  describe '#comments_text_list' do

  end
  describe '#total_character_count' do

  end
  describe '#average_character_count' do

  end
  describe '#max_character_count' do

  end
  describe '#min_character_count' do

  end
  describe '#total_word_count' do

  end
  describe '#average_word_count' do

  end
  describe '#max_word_count' do

  end
  describe '#min_word_count' do

  end
  describe '#average_score' do

  end
  describe '#max_question_score' do

  end
  describe '#min_question_score' do

  end
  describe '#num_questions' do

  end
end