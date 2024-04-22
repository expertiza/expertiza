require 'rails_helper'
require 'fakeredis/rspec'

RSpec.describe QuestionnaireHelper, type: :helper do
  describe '.adjust_advice_size' do
    let(:questionnaire) { FactoryBot.create(:questionnaire) }
    let(:scored_question) { FactoryBot.create(:scored_question) }
    let(:non_scored_question) { FactoryBot.create(:question) }

    context 'when question is a ScoredQuestion' do
      it 'adjusts advice size based on questionnaire scores' do
        scored_question = FactoryBot.create(:scored_question)
        FactoryBot.create(:question_advice, question: scored_question, score: 5)
        questionnaire = FactoryBot.create(:questionnaire)
        questionnaire.min_question_score = 1
        questionnaire.max_question_score = 10
        described_class.adjust_advice_size(questionnaire, scored_question)
        expect(scored_question.question_advices.count).to eq(10)
      end
    end

    # context 'when question is not a ScoredQuestion' do
    #   it 'does not adjust advice size' do
    #     FactoryBot.create_list(:question_advice, 6, question: non_scored_question, score: 5)
    #     described_class.adjust_advice_size(questionnaire, non_scored_question)
    #     expect(non_scored_question.question_advices.count).to eq(6)
    #   end
    # end
  end

  describe '.update_questionnaire_questions' do
    let(:params) { { question: { '1' => { body: 'Updated body' } } } }
    let(:question) { FactoryBot.create(:question) } # Make sure :question factory creates an instance of the Question class

    before do
      allow(helper).to receive(:params).and_return(params)
    end

    it 'updates attributes of questionnaire questions based on form data' do
      allow(QuestionnaireHelper).to receive(:update_questionnaire_questions)
      described_class.update_questionnaire_questions
      question.reload
      expect(question.body).to eq('Updated body')
    end

    # it 'does not modify unchanged attributes' do
    #   allow(QuestionnaireHelper).to receive(:update_questionnaire_questions)
    #   described_class.update_questionnaire_questions
    #   question.reload
    #   expect(question.title).to eq('Original title')
    # end
  end

  # describe '.questionnaire_factory' do
  #   it 'returns an instance of the corresponding questionnaire class' do
  #     type = 'ReviewQuestionnaire'
  #     expect(described_class.questionnaire_factory(type)).to be_an_instance_of(ReviewQuestionnaire)
  #   end

  #   it 'sets an error flash message if type is not found in the map' do
  #     type = 'UnknownQuestionnaire'
  #     expect { described_class.questionnaire_factory(type) }.to change { flash[:error] }.from(nil).to('Error: Undefined Questionnaire')
  #   end
  # end
end
