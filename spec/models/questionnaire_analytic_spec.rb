class QuestionnaireAnalyticTestDummyClass 
  attr_accessor :questionnaires
  require 'analytic/questionnaire_analytic'
  include QuestionnaireAnalytic
  def initialize(questionnaires)
    @questionnaires = questionnaires
  end

  describe QuestionnaireAnalytic do
  let(:questionnaire) { Questionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: "xyz", private: 0, max_question_score: 20, instructor_id: 1234 }
  describe '#types' do
  	context 'when there are two questionnaires, with differing types' do
      it 'returns an array of size two with the two types of questionnaires' do
        dc = QuestionnaireAnalyticTestDummyClass.new([questionnaire, questionnaire1])
        allow(questionnaire).to receive(:type).and_return('MetareviewQuestionnaire')
        allow(questionnaire1).to receive(:type).and_return('AuthorFeedbackQuestionnaire')
        expect(QuestionnaireAnalyticTestDummyClass::QuestionnaireAnalytic.types.length).to eq(2)
  	  end
    end
  end
  describe '#num_questions' do

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