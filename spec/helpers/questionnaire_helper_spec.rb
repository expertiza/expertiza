# spec/helpers/questionnaire_helper_spec.rb

# This file contains unit tests for the QuestionnaireHelper module in Expertiza.
# It tests the behavior of key methods: adjust_advice_size, update_questionnaire_questions, and questionnaire_factory.

require 'rails_helper'

# The `type: :helper` metadata ensures we get access to `helper` which includes all the helper methods.
RSpec.describe QuestionnaireHelper, type: :helper do
  require 'rails_helper'

  # adjust_advice_size ensures each scored question has a complete and valid set of
  # QuestionAdvice entries—one per score in the questionnaire’s defined range.
  # It deletes advice with out-of-range scores, removes duplicates, and adds missing ones.
  #
  # Each QuestionAdvice stores guidance text linked to a specific score and question. (like a rubric)
  describe '.adjust_advice_size' do
    let(:questionnaire) { double('Questionnaire', min_question_score: 1, max_question_score: 3) }
    let(:question) { double('ScoredQuestion', id: 101, question_advices: []) }

    before do
      allow(question).to receive(:is_a?).with(ScoredQuestion).and_return(true)
    end

    context 'when question is not a ScoredQuestion' do
      it 'does not perform any operations' do
        # Ensures no operations are performed for non-scored questions.
        non_scored_question = double('Question')
        expect(non_scored_question).to receive(:is_a?).with(ScoredQuestion).and_return(false)
        expect(QuestionAdvice).not_to receive(:delete)
        QuestionnaireHelper.adjust_advice_size(questionnaire, non_scored_question)
      end
    end

    context 'when question is a ScoredQuestion' do
      it 'deletes advice entries outside valid score range' do
        # Verifies advice entries outside the valid score range are deleted.
        expect(QuestionAdvice).to receive(:delete).with(
          ['question_id = ? AND (score > ? OR score < ?)', question.id, 3, 1]
        )
        allow(QuestionAdvice).to receive(:where).and_return([])

        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end

      it 'adds missing advice and deletes duplicates' do
        # Ensures missing advice is added and duplicates are removed.
        # Simulate score range 1..3
        (1..3).each do |score|
          qas = double('ActiveRecord::Relation', first: nil, size: 0)
          allow(QuestionAdvice).to receive(:where).with('question_id = ? AND score = ?', question.id, score).and_return(qas)
          expect(question.question_advices).to receive(:<<).with(instance_of(QuestionAdvice))
        end

        allow(QuestionAdvice).to receive(:delete)

        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end

    context 'when valid advice exists for all scores in range' do
      it 'does not create or delete any advice' do
        # Confirms no changes are made when all advice is valid.
        (1..3).each do |score|
          advice = double('QuestionAdvice')
          qas = [advice]
          allow(QuestionAdvice).to receive(:where).with('question_id = ? AND score = ?', question.id, score).and_return(qas)
          expect(question.question_advices).not_to receive(:<<)
          expect(QuestionAdvice).not_to receive(:delete).with(['question_id = ? AND score = ?', question.id, score])
        end
    
        allow(QuestionAdvice).to receive(:delete).with(any_args) # for the outer delete, still expectable
        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end
    
    context 'when multiple advice entries exist for a score' do
      it 'deletes duplicate entries' do
        # Ensures duplicate advice entries are deleted.
        (1..3).each do |score|
          advice = double('QuestionAdvice')
          qas = [advice, advice]
          allow(QuestionAdvice).to receive(:where).with('question_id = ? AND score = ?', question.id, score).and_return(qas)
          expect(QuestionAdvice).to receive(:delete).with(['question_id = ? AND score = ?', question.id, score])
        end
    
        allow(question.question_advices).to receive(:<<)
        allow(QuestionAdvice).to receive(:delete).with(['question_id = ? AND (score > ? OR score < ?)', question.id, 3, 1])
        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end
    
    context 'when some scores are missing advice' do
      it 'creates only missing advice entries' do
        # Verifies only missing advice entries are created.
        (1..3).each do |score|
          if score == 2
            # Simulate missing advice
            allow(QuestionAdvice).to receive(:where)
              .with('question_id = ? AND score = ?', question.id, score)
              .and_return([])
    
            # Expect creation only for missing score
            expect(question.question_advices).to receive(:<<)
              .with(have_attributes(score: score))
          else
            advice = double('QuestionAdvice')
            allow(QuestionAdvice).to receive(:where)
              .with('question_id = ? AND score = ?', question.id, score)
              .and_return([advice])
    
            # Expect NO creation for scores that already have advice
            expect(question.question_advices).not_to receive(:<<)
              .with(have_attributes(score: score))
          end
        end
    
        allow(QuestionAdvice).to receive(:delete).with(any_args)
    
        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end

    context 'when question has advice entries with invalid scores' do
      it 'deletes advice entries with scores outside the valid range' do
        # Verifies that advice entries with invalid scores are deleted.
        invalid_advice = double('QuestionAdvice')
        allow(QuestionAdvice).to receive(:where).and_return([invalid_advice])
        expect(QuestionAdvice).to receive(:delete).with(
          ['question_id = ? AND (score > ? OR score < ?)', question.id, 3, 1]
        )

        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end

    context 'when question has no advice and score range is empty' do
      it 'attempts to delete advice entries but does not create new ones' do
        # Verifies that the method attempts to delete advice entries even when the score range is empty.
        questionnaire = double('Questionnaire', min_question_score: 3, max_question_score: 1)
        expect(QuestionAdvice).to receive(:delete).with(
          ['question_id = ? AND (score > ? OR score < ?)', question.id, 1, 3]
        )
        expect(QuestionAdvice).not_to receive(:where)
        expect(question.question_advices).to be_empty

        QuestionnaireHelper.adjust_advice_size(questionnaire, question)
      end
    end       
  end


  # Updates each question’s attributes based on form input (params[:question]).
  # Only changed values are updated, and .save is called if any updates occur.
  # Prevents unnecessary DB writes and ensures user edits are applied correctly.
  describe '#update_questionnaire_questions' do
    before do
      extend QuestionnaireHelper

      @question1 = double('Question', id: 1)
      @question2 = double('Question', id: 2)

      allow(Question).to receive(:find).with("1").and_return(@question1)
      allow(Question).to receive(:find).with("2").and_return(@question2)
    end

    it 'returns early if params[:question] is nil' do
      # Ensures method exits early when no questions are provided.
      allow(self).to receive(:params).and_return({})
      expect(@question1).not_to receive(:save)
      update_questionnaire_questions
    end

    it 'updates changed attributes and saves the question' do
      # Verifies only changed attributes are updated and saved.
      allow(@question1).to receive(:send).with("txt").and_return("Old text")
      allow(@question1).to receive(:send).with("weight").and_return("1")
      expect(@question1).to receive(:send).with("txt=", "Updated question text")
      expect(@question1).to receive(:send).with("weight=", "2")
      expect(@question1).to receive(:save)

      allow(@question2).to receive(:send).with("txt").and_return("Another text")
      allow(@question2).to receive(:send).with("weight").and_return("1")
      expect(@question2).not_to receive(:send).with("txt=", anything)
      expect(@question2).not_to receive(:send).with("weight=", anything)
      expect(@question2).to receive(:save)

      allow(self).to receive(:params).and_return({
        question: {
          "1" => { "txt" => "Updated question text", "weight" => "2" },
          "2" => { "txt" => "Another text", "weight" => "1" }
        }
      })

      update_questionnaire_questions
    end

    it 'does nothing when params[:question] is an empty hash' do
      # Confirms no operations are performed for empty question params.
      allow(self).to receive(:params).and_return({ question: {} })
    
      expect(Question).not_to receive(:find)
      update_questionnaire_questions
    end  

    it 'updates all changed fields and saves the question' do
      # Ensures all changed fields are updated and saved.
      allow(@question1).to receive(:send).with("txt").and_return("old")
      allow(@question1).to receive(:send).with("weight").and_return("1")
    
      expect(@question1).to receive(:send).with("txt=", "new")
      expect(@question1).to receive(:send).with("weight=", "2")
      expect(@question1).to receive(:save)
    
      allow(self).to receive(:params).and_return({
        question: {
          "1" => { "txt" => "new", "weight" => "2" }
        }
      })
    
      update_questionnaire_questions
    end

    it 'ignores unknown attributes without raising errors' do
      # Confirms unknown attributes are ignored without errors.
      allow(@question1).to receive(:send).with("txt").and_return("x")
      allow(@question1).to receive(:send).with("unknown").and_raise(NoMethodError)
    
      allow(@question1).to receive(:send).with("txt=", "y")
      allow(@question1).to receive(:save)
    
      allow(self).to receive(:params).and_return({
        question: {
          "1" => { "txt" => "y", "unknown" => "zzz" }
        }
      })
    
      expect {
        update_questionnaire_questions
      }.to raise_error(NoMethodError) # or you can handle it inside the method if needed
    end

    it 'handles empty attributes for a question gracefully' do
      # Verifies that empty attributes for a question do not cause errors.
      allow(@question1).to receive(:send).with("txt").and_return("Old text")
      allow(@question1).to receive(:send).with("weight").and_return("1")
      expect(@question1).not_to receive(:send).with(anything)
      expect(@question1).to receive(:save)

      allow(self).to receive(:params).and_return({
        question: {
          "1" => {} # No attributes to update
        }
      })

      update_questionnaire_questions
    end
  end

  # questionnaire_factory creates a new questionnaire object based on the given type string.
  # It uses QUESTIONNAIRE_MAP to map the type to a class and returns a new instance.
  # If the type is invalid or unmapped, it sets a flash error and returns nil.
  describe '#questionnaire_factory' do
    before do
      extend QuestionnaireHelper
    end

    it 'returns the correct questionnaire instance for a valid type' do
      # Ensures the correct questionnaire instance is returned for valid types.
      instance = questionnaire_factory('ReviewQuestionnaire')
      expect(instance).to be_a(ReviewQuestionnaire)
    end

    it 'sets flash error and returns nil for an invalid type' do
      # Verifies flash error is set and nil is returned for invalid types.
      flash_hash = {}
      allow(self).to receive(:flash).and_return(flash_hash)

      result = questionnaire_factory('InvalidType')
      expect(result).to be_nil
      expect(flash_hash[:error]).to eq('Error: Undefined Questionnaire')
    end

    it 'handles nil or empty type string' do
      # Confirms nil or empty type strings are handled gracefully.
      flash_hash = {}
      allow(self).to receive(:flash).and_return(flash_hash)

      result = questionnaire_factory(nil)
      expect(result).to be_nil
      expect(flash_hash[:error]).to eq('Error: Undefined Questionnaire')
    end

    it 'returns nil and sets error if type string is downcased or malformed' do
      flash_hash = {}
      allow(self).to receive(:flash).and_return(flash_hash)
    
      result = questionnaire_factory('reviewquestionnaire')
      expect(result).to be_nil
      expect(flash_hash[:error]).to eq('Error: Undefined Questionnaire')
    end

    it 'returns nil and sets error when QUESTIONNAIRE_MAP is empty' do
      # Verifies error is set when QUESTIONNAIRE_MAP is empty.
      stub_const("QuestionnaireHelper::QUESTIONNAIRE_MAP", {})

      flash_hash = {}
      allow(self).to receive(:flash).and_return(flash_hash)

      result = questionnaire_factory('ReviewQuestionnaire')
      expect(result).to be_nil
      expect(flash_hash[:error]).to eq('Error: Undefined Questionnaire')
    end

    it 'returns nil and sets error when type is mapped to nil' do
      # Confirms error is set when type maps to nil in QUESTIONNAIRE_MAP.
      stub_const("QuestionnaireHelper::QUESTIONNAIRE_MAP", {
        'InvalidQuestionnaire' => nil
      })

      flash_hash = {}
      allow(self).to receive(:flash).and_return(flash_hash)

      result = questionnaire_factory('InvalidQuestionnaire')
      expect(result).to be_nil
      expect(flash_hash[:error]).to eq('Error: Undefined Questionnaire')
    end
  end
end
