require 'rails_helper'
require 'questionnaire_helper'

RSpec.describe QuestionnaireHelper, type: :helper do
  describe '.adjust_advice_size' do
    let(:questionnaire) { double('Questionnaire', max_question_score: 10, min_question_score: 1) }
    let(:scored_question) { double('ScoredQuestion', id: 1, question_advices: []) }
    let(:non_scored_question) { double('Question')}
    let(:question_advice) { double('QuestionAdvice') }

    context 'when question is a ScoredQuestion' do
      it 'adjusts advice size based on questionnaire scores' do
    allow(QuestionAdvice).to receive(:where).and_return([])
    allow(QuestionAdvice).to receive(:new).and_return(double('QuestionAdvice', save: true))
    allow(scored_question).to receive(:is_a?).with(ScoredQuestion).and_return(true)
    described_class.adjust_advice_size(questionnaire, scored_question)
    expect(QuestionAdvice).to have_received(:where).exactly(10).times
    expect(scored_question.question_advices.size).to eq(10)
  end
    end

    context 'when question is not a ScoredQuestion' do
      it 'does not adjust advice size' do
        allow(QuestionAdvice).to receive(:where)
        allow(QuestionAdvice).to receive(:new)
        allow(scored_question).to receive(:is_a?).with(ScoredQuestion).and_return(false)
        described_class.adjust_advice_size(questionnaire, non_scored_question)
        expect(QuestionAdvice).not_to have_received(:where)
        expect(QuestionAdvice).not_to have_received(:new)
      end
    end
  end

  describe '.questionnaire_factory' do
    context 'when given a valid type' do
      it 'returns an instance of the specified questionnaire type' do
        questionnaire_type = 'ReviewQuestionnaire'
        expect(helper.questionnaire_factory(questionnaire_type)).to be_an_instance_of(ReviewQuestionnaire)
      end
    end

    context 'when given an invalid type' do
      it 'sets an error flash message' do
        questionnaire_type = 'UnknownQuestionnaire'
        expect { helper.questionnaire_factory(questionnaire_type) }.to change { flash[:error] }.from(nil).to('Error: Undefined Questionnaire')
      end
    end
  end
end
