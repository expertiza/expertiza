require 'rails_helper'
require 'questionnaire_helper'

RSpec.describe QuestionnaireHelper, type: :helper do
  describe '.adjust_advice_size' do
    let(:questionnaire) { double('Questionnaire', max_question_score: 10, min_question_score: 1) }
    let(:scored_question) { double('ScoredQuestion', id: 1) }
    let(:non_scored_question) { double('Question') }
    let(:question_advice) { double('QuestionAdvice') }

    context 'when question is a ScoredQuestion' do
      it 'adjusts advice size based on questionnaire scores' do
        allow(QuestionAdvice).to receive(:where).and_return([])
        allow(QuestionAdvice).to receive(:new).and_return(question_advice)
        allow(scored_question).to receive(:is_a?).with(ScoredQuestion).and_return(true)
        allow(scored_question).to receive(:question_advices).and_return([])

        described_class.adjust_advice_size(questionnaire, scored_question)

        expect(scored_question).to have_received(:question_advice).exactly(10).times
        expect(question_advice).to have_received(:save).exactly(10).times
      end
    end

    context 'when question is not a ScoredQuestion' do
      it 'does not adjust advice size' do
        allow(non_scored_question).to receive(:is_a?).with(ScoredQuestion).and_return(false)

        described_class.adjust_advice_size(questionnaire, non_scored_question)

        expect(non_scored_question).not_to have_received(:question_advice)
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

  describe '.update_questionnaire_questions' do
    let(:params) { { question: { '1' => { body: 'Updated body' } } } }
    let(:question) { double('Question') }

    before do
      allow(Question).to receive(:find).and_return(question)
      allow(question).to receive(:save)
    end

    context 'when params[:question] is not nil' do
      it 'updates attributes of questionnaire questions based on form data' do
        helper.update_questionnaire_questions
        expect(question).to have_received(:save)
      end

      it 'does not modify unchanged attributes' do
        allow(question).to receive(:title).and_return('Original title')
        helper.update_questionnaire_questions
        expect(question).not_to have_received(:title=)
      end
    end

    context 'when params[:question] is nil' do
      it 'returns without making any changes' do
        allow(helper).to receive(:params).and_return(nil)
        helper.update_questionnaire_questions
        expect(question).not_to have_received(:save)
      end
    end
  end
end
