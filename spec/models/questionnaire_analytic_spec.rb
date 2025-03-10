class QuestionnaireAnalyticTestDummyClass
  attr_accessor :questions
  require 'analytic/questionnaire_analytic'
  include QuestionnaireAnalytic
  def initialize(questions)
    @questions = questions
  end
end

describe QuestionnaireAnalytic do
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { TextArea.new(id: 1, weight: 2, break_before: true) }
  let(:question3) { TextArea.new(id: 2, weight: 2, break_before: true) }
  describe '#types' do
    context 'when there are two questions, with differing types' do
      it 'returns an array of size two with the two types of questions' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2])
        allow(question).to receive(:type).and_return('Criterion')
        allow(question2).to receive(:type).and_return('TextArea')
        expect(dc.types.length).to eq(2)
        expect(dc.types).to eq(%w[Criterion TextArea])
      end
    end
    context 'when there are two questions, with the same types' do
      it 'returns an array of size one with the one type of questions' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question3, question2])
        allow(question3).to receive(:type).and_return('TextArea')
        allow(question2).to receive(:type).and_return('TextArea')
        expect(dc.types.length).to eq(1)
        expect(dc.types).to eq(['TextArea'])
      end
    end
    context 'when there are no questions' do
      it 'returns an empty array' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.types.empty?).to eq(true)
      end
    end
  end
  describe '#num_questions' do
    context 'when there are no questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.num_questions).to eq(0)
      end
    end
    context 'when there are three questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        expect(dc.num_questions).to eq(3)
      end
    end
  end
  describe '#questions_text_list' do
    context 'when there are no questions' do
      it 'returns an array that is [0]' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.questions_text_list).to eq([0])
      end
    end
    context 'when there are three questions with text' do
      it 'returns an array of size 3 with the text' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:txt).and_return('What is the answer?')
        allow(question2).to receive(:txt).and_return('What is 1 + 1?')
        allow(question3).to receive(:txt).and_return('What is life?')
        expect(dc.questions_text_list.length).to eq(3)
        expect(dc.questions_text_list).to eq(['What is the answer?', 'What is 1 + 1?', 'What is life?'])
      end
    end
  end
  describe '#word_count_list' do
    context 'when there are no questions' do
      it 'returns an array that is [0]' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.word_count_list).to eq([0])
      end
    end
    context 'when there are three questions with text' do
      it 'returns an array of size 3 with the word count' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:word_count).and_return(100)
        allow(question2).to receive(:word_count).and_return(75)
        allow(question3).to receive(:word_count).and_return(50)
        expect(dc.word_count_list.length).to eq(3)
        expect(dc.word_count_list).to eq([100, 75, 50])
      end
    end
  end
  describe '#total_word_count' do
    context 'when there are no questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.total_word_count).to eq(0)
      end
    end
    context 'when there are three questions with text' do
      it 'returns an the sum of the word count which is 225' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:word_count).and_return(100)
        allow(question2).to receive(:word_count).and_return(75)
        allow(question3).to receive(:word_count).and_return(50)
        expect(dc.total_word_count).to eq(225)
      end
    end
  end
  describe '#average_word_count' do
    context 'when there are no questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.average_word_count).to eq(0)
      end
    end
    context 'when there are three questions with text' do
      it 'returns an the average of the word count which is 75' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:word_count).and_return(100)
        allow(question2).to receive(:word_count).and_return(75)
        allow(question3).to receive(:word_count).and_return(50)
        expect(dc.average_word_count).to eq(75)
      end
    end
  end
  describe '#character_count_list' do
    context 'when there are no questions' do
      it 'returns an array that is [0]' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.character_count_list).to eq([0])
      end
    end
    context 'when there are three questions with text' do
      it 'returns an array of size 3 with the character count' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:character_count).and_return(100)
        allow(question2).to receive(:character_count).and_return(75)
        allow(question3).to receive(:character_count).and_return(50)
        expect(dc.character_count_list.length).to eq(3)
        expect(dc.character_count_list).to eq([100, 75, 50])
      end
    end
  end
  describe '#total_character_count' do
    context 'when there are no questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.total_character_count).to eq(0)
      end
    end
    context 'when there are three questions with text' do
      it 'returns 225' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:character_count).and_return(100)
        allow(question2).to receive(:character_count).and_return(75)
        allow(question3).to receive(:character_count).and_return(50)
        expect(dc.total_character_count).to eq(225)
      end
    end
  end
  describe '#average_character_count' do
    context 'when there are no questions' do
      it 'returns 0' do
        dc = QuestionnaireAnalyticTestDummyClass.new([])
        expect(dc.average_character_count).to eq(0)
      end
    end
    context 'when there are three questions with text' do
      it 'returns 75' do
        dc = QuestionnaireAnalyticTestDummyClass.new([question, question2, question3])
        allow(question).to receive(:character_count).and_return(100)
        allow(question2).to receive(:character_count).and_return(75)
        allow(question3).to receive(:character_count).and_return(50)
        expect(dc.average_character_count).to eq(75)
      end
    end
  end
end
