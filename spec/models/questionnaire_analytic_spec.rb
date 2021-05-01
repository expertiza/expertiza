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
        expect(dc.types).to eq(['Criterion', 'TextArea'])
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

  end
  describe '#word_count_list' do

  end
  describe '#total_word_count' do

  end
  describe '#average_word_count' do

  end
  describe '#character_count_list' do

  end
  describe '#total_character_count' do

  end
  describe '#average_character_count' do

  end
end