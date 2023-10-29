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
    context 'there are no answers associated with the response' do
      it 'will return [0]' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.character_count_list).to eq([0])
      end
    end
    context 'there are three answers associated with the response, with character counts of 50, 75, and 100' do
      it 'will return [50, 75, 100]' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:character_count).and_return(50)
        allow(answer2).to receive(:character_count).and_return(75)
        allow(answer3).to receive(:character_count).and_return(100)
        expect(dc.character_count_list).to eq([50, 75, 100])
      end
    end
  end
  describe '#question_score_list' do
    context 'there are no answers associated with the response' do
      it 'will return [0]' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.question_score_list).to eq([0])
      end
    end
    context 'there are three answers associated with the response, with question scores of 50, 75, and 100' do
      it 'will return [50, 75, 100]' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:score).and_return(50)
        allow(answer2).to receive(:score).and_return(75)
        allow(answer3).to receive(:score).and_return(100)
        expect(dc.question_score_list).to eq([50, 75, 100])
      end
    end
  end
  describe '#comments_text_list' do
    context 'there are no answers associated with the response' do
      it 'will return []' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.comments_text_list).to eq([])
      end
    end
    context 'there are three answers associated with the response, with comment text of
    \'This is a very good submission! \',
    \'Well written comments and easy to follow documentation. \', and
    \'I think this could have been better if your tests were less shallow.\'' do
      it 'will return an array of the text above, in that order' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:comments).and_return('This is a very good submission!')
        allow(answer2).to receive(:comments).and_return('Well written comments and easy to follow documentation.')
        allow(answer3).to receive(:comments).and_return('I think this could have been better if your tests were less shallow.')
        expect(dc.comments_text_list).to eq(['This is a very good submission!', 'Well written comments and easy to follow documentation.',
                                             'I think this could have been better if your tests were less shallow.'])
      end
    end
  end
  describe '#total_character_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.total_character_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with character counts of 50, 75, and 100' do
      it 'will return 225' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:character_count).and_return(50)
        allow(answer2).to receive(:character_count).and_return(75)
        allow(answer3).to receive(:character_count).and_return(100)
        expect(dc.total_character_count).to eq(225)
      end
    end
  end
  describe '#average_character_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.average_character_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with character counts of 50, 75, and 100' do
      it 'will return 75' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:character_count).and_return(50)
        allow(answer2).to receive(:character_count).and_return(75)
        allow(answer3).to receive(:character_count).and_return(100)
        expect(dc.average_character_count).to eq(75)
      end
    end
  end
  describe '#max_character_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.max_character_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with character counts of 50, 75, and 100' do
      it 'will return 100' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:character_count).and_return(50)
        allow(answer2).to receive(:character_count).and_return(75)
        allow(answer3).to receive(:character_count).and_return(100)
        expect(dc.max_character_count).to eq(100)
      end
    end
  end
  describe '#min_character_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.min_character_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with character counts of 50, 75, and 100' do
      it 'will return 50' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:character_count).and_return(50)
        allow(answer2).to receive(:character_count).and_return(75)
        allow(answer3).to receive(:character_count).and_return(100)
        expect(dc.min_character_count).to eq(50)
      end
    end
  end
  describe '#total_word_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.total_word_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with word counts of 50, 75, and 100' do
      it 'will return 225' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:word_count).and_return(50)
        allow(answer2).to receive(:word_count).and_return(75)
        allow(answer3).to receive(:word_count).and_return(100)
        expect(dc.total_word_count).to eq(225)
      end
    end
  end
  describe '#average_word_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.average_word_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with word counts of 50, 75, and 100' do
      it 'will return 75' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:word_count).and_return(50)
        allow(answer2).to receive(:word_count).and_return(75)
        allow(answer3).to receive(:word_count).and_return(100)
        expect(dc.average_word_count).to eq(75)
      end
    end
  end
  describe '#max_word_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.max_word_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with word counts of 50, 75, and 100' do
      it 'will return 100' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:word_count).and_return(50)
        allow(answer2).to receive(:word_count).and_return(75)
        allow(answer3).to receive(:word_count).and_return(100)
        expect(dc.max_word_count).to eq(100)
      end
    end
  end
  describe '#min_word_count' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.min_word_count).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with word counts of 50, 75, and 100' do
      it 'will return 50' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:word_count).and_return(50)
        allow(answer2).to receive(:word_count).and_return(75)
        allow(answer3).to receive(:word_count).and_return(100)
        expect(dc.min_word_count).to eq(50)
      end
    end
  end
  describe '#average_score' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.average_score).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with scores of 50, 75, and 100' do
      it 'will return 75' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:score).and_return(50)
        allow(answer2).to receive(:score).and_return(75)
        allow(answer3).to receive(:score).and_return(100)
        expect(dc.average_score).to eq(75)
      end
    end
  end
  describe '#max_question_score' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.max_question_score).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with scores of 50, 75, and 100' do
      it 'will return 100' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:score).and_return(50)
        allow(answer2).to receive(:score).and_return(75)
        allow(answer3).to receive(:score).and_return(100)
        expect(dc.max_question_score).to eq(100)
      end
    end
  end
  describe '#min_question_score' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.min_question_score).to eq(0)
      end
    end
    context 'there are three answers associated with the response, with scores of 50, 75, and 100' do
      it 'will return 50' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        allow(answer1).to receive(:score).and_return(50)
        allow(answer2).to receive(:score).and_return(75)
        allow(answer3).to receive(:score).and_return(100)
        expect(dc.min_question_score).to eq(50)
      end
    end
  end
  describe '#num_questions' do
    context 'there are no answers associated with the response' do
      it 'will return 0' do
        dc = ResponseAnalyticTestDummyClass.new([])
        expect(dc.num_questions).to eq(0)
      end
    end
    context 'there are three answers associated with the response' do
      it 'will return 3' do
        dc = ResponseAnalyticTestDummyClass.new(@scores)
        expect(dc.num_questions).to eq(3)
      end
    end
  end
end
